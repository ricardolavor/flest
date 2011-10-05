package flest.service
{	
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import flest.service.filter.JSONFilter;
	import flest.util.Inflector;
	import flest.util.ObjUtil;
	import flest.util.StringUtil;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPMultiService;
	import mx.rpc.http.HTTPService;
	import mx.rpc.http.Operation;
	import mx.rpc.remoting.Operation;
	
	internal class AbstractResource
	{
		private var services: Dictionary = new Dictionary();
		public var pathObjs: Array;
		public var baseURL: String;		
		public var jsonIgnoreClassName: Boolean;
		public var format: String;
		public var modelPackage: String;
		
		private function createJSONService(): HTTPMultiService{
			var svc: HTTPMultiService = new HTTPMultiService(baseURL);
			svc.contentType = "application/json";
			var filter: JSONFilter = new JSONFilter();
			filter.modelPackage = modelPackage;
			svc.serializationFilter = filter;
			return svc;			
		}
		
		private function getServiceControl(format: String = null): AbstractService{
			if (!StringUtil.stringHasValue(format))
				format = this.format;
			var result: AbstractService = services[format] as AbstractService;
			switch(format)
			{
				case Formats.JSON:
				{
					if (result)
						((result as HTTPMultiService).serializationFilter as JSONFilter).modelPackage = modelPackage;
					else
					{
						result = createJSONService();
						services[format] = result;
					}
					break;
				}
					
				//todo: implementar os outros formatos	
					
				default:
				{
					throw new Error("unexpected format");
				}
			}	
			return result;
		}
				
		private function copyOptionsToConfig(options: Object, config: ResourceConfig): void{			
			var destProps: XMLList = describeType(config)..variable;			
			for(var optProp: String in options)
				if (destProps.(@name == optProp).length() == 0)
					throw new Error(StringUtil.substitute("Unrecognized option '{0}'", optProp)); 
			for each(var cfgProp: XML in destProps)
			{
				var propName: String = cfgProp.@name;
				if (options[propName])
					config[propName] = options[propName];
			}			
		}
								
		protected function get media(): String{
			if (format == Formats.JSON)
				return ".json";
			else if (format == Formats.XML)
				return ".xml";
			return "";
		}

		protected function mountURL(includeId: Boolean, includeMedia: Boolean, customAction: String = ""): String{
			var url:String = '';
			for (var i: int = 0; i < pathObjs.length; i++){
				var item: Object = pathObjs[i];
				url += '/';
				if (item is String)
					url += item;
				else
				{
					var className: String = ObjUtil.getClassName(item);
					url += Inflector.pluralize(className);
					if (item.id)
						if (i < pathObjs.length - 1 || includeId) 
							url += '/' + item.id;
				}
			}
			if (StringUtil.stringHasValue(customAction))
				url += "/" + customAction;
			if (StringUtil.stringHasValue(url) && includeMedia)
				url += media;
			return baseURL + url;
		}
		
		protected function createOperation(operationName: String, config: ResourceConfig, url: String, defaultParam: Object = null, defaultMethod: String = "GET"): AbstractOperation{
			var customFormat: String = (config && StringUtil.stringHasValue(config.format)) ? config.format : this.format;
			if (customFormat == Formats.JSON || customFormat == Formats.XML){
				var httpOperation: mx.rpc.http.Operation = new mx.rpc.http.Operation(getServiceControl(customFormat) as HTTPMultiService, operationName);
				var method: String = config && config.method ? config.method.toUpperCase() : defaultMethod;			
				if (method == "PUT" || method == "DELETE")
				{
					httpOperation.headers['X_HTTP_METHOD_OVERRIDE'] = method;
					method = "POST";
				}
				httpOperation.url = url;				
				httpOperation.resultFormat = customFormat == Formats.JSON ? HTTPService.RESULT_FORMAT_TEXT : HTTPService.RESULT_FORMAT_E4X;
				httpOperation.method = method;
				var argNames: Array = defaultParam ? [Inflector.underscore(ObjUtil.getRemoteClassName(defaultParam))] : null;
				if (config && config.params)
				{
					if (!argNames)
						argNames = new Array();
					for(var prop: String in config.params)
						argNames.push(prop);
				}
				httpOperation.argumentNames = argNames;
				if (config && customFormat == Formats.JSON)
				{
					var filter: JSONFilter = (getServiceControl(customFormat) as HTTPMultiService).serializationFilter as JSONFilter;
					filter.defineJSONIgnoreClassNameForOperation(httpOperation, config.jsonIgnoreClassName);					
				}
				return httpOperation;				
			}
			else
			{
				//todo: finalizar esse trecho de código
				var remoteOperation: mx.rpc.remoting.Operation = new mx.rpc.remoting.Operation(getServiceControl(customFormat), operationName);
				return remoteOperation;
			}
		}		
		
		protected function prepareToken(actionName: String, onSuccessOrOptions: *, url: String, defaultParam: Object = null, defaultMethod: String = "GET"): AsyncToken{
			var config: ResourceConfig = null;
			var success: Function = null;
			var error: Function = null;
			var params: Array = defaultParam ? [defaultParam] : null;
			if (onSuccessOrOptions != null)
				if (onSuccessOrOptions is Function)
					success = onSuccessOrOptions;
				else
				{
					config = new ResourceConfig();
					copyOptionsToConfig(onSuccessOrOptions, config);
					success = config.success;
					error = config.error;
					if (config.params)
					{
						if (!params)
							params = new Array();
						for each(var propValue: Object in config.params)
							params.push(propValue);
					}
				}
			var operation: AbstractOperation = createOperation(actionName, config, url, defaultParam, defaultMethod);
			var token: AsyncToken = operation.send(params);
			if (success != null || error != null)
			{
				var responder: Responder = new Responder(
					function (e: ResultEvent): void{
						if (success != null)
							success(e.result);
					},
					function (e: FaultEvent): void{
						if (error != null)
							error(e.fault.faultString);
					}
				);
				token.addResponder(responder);
			}
			return token;			
		}
												
		public function action(name:String, onSuccessOrOptions: * = null):AsyncToken
		{
			//todo: Definir como vai ser a URL
			return prepareToken(name, onSuccessOrOptions, mountURL(true, false, name));
		}		
	}
}
