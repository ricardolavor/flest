package flest.service
{
	import avmplus.getQualifiedClassName;
	
	import flash.utils.Dictionary;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPMultiService;
	import mx.rpc.http.Operation;
	import mx.rpc.remoting.Operation;
	
	import flest.util.Inflector;
	import flest.util.ObjUtil;
	import flest.util.StringUtil;
	import flest.service.filter.JSONFilter;
	
	internal class AbstractResource
	{
		private var _format: String;
		protected var serviceControl: AbstractService;
		public var pathObjs: Array;
		public var baseURL: String;
		
		private function createServiceControl(format: String): AbstractService{
			switch(format)
			{
				case Formats.JSON:
				{
					var svc: mx.rpc.http.HTTPMultiService = new mx.rpc.http.HTTPMultiService(baseURL);
					svc.contentType = "application/json";
					svc.serializationFilter = new JSONFilter();
					return svc;
				}
					
				//todo: implementar os outros formatos	
					
				default:
				{
					throw new Error("unexpected format");
				}
			}	
		}				
		
		public function get format(): String{
			return _format;
		}

		protected function mountURL(): String{
			var url:String = '';
			for each (var item: Object in pathObjs)
			{
				url += '/';
				if (item is String)
					url += item;
				else
				{
					var className: String = ObjUtil.getClassName(item);
					url += Inflector.pluralize(className);
					if (item.id)
						url += '/' + item.id;
				}
			}
			switch(format)
			{
				case Formats.JSON:
				{
					url += ".json"
					break;
				}
					
				case Formats.XML:
				{
					url += ".xml";
					break;
				}					
			}
			return baseURL + url;
		}
			
		protected function createOperation(operationName: String, config: ResourceConfig, defaultParam: Object = null, defaultMethod: String = "GET"): AbstractOperation{
			if (config && config.format)
				format = config.format;
			if (format == Formats.JSON || format == Formats.XML){
				var httpOperation: mx.rpc.http.Operation = new mx.rpc.http.Operation(serviceControl as HTTPMultiService, operationName);
				httpOperation.url = mountURL();
				httpOperation.method = config && config.method ? config.method.toUpperCase() : defaultMethod;			
				httpOperation.resultFormat = "text";
				var argNames: Array = defaultParam ? [ObjUtil.getClassName(defaultParam)] : null;
				if (config && config.params)
				{
					if (!argNames)
						argNames = new Array();
					for(var prop: String in config.params)
						argNames.push(prop);
				}
				httpOperation.argumentNames = argNames;
				return httpOperation;				
			}
			else
			{
				//todo: finalizar esse trecho de código
				var remoteOperation: mx.rpc.remoting.Operation = new mx.rpc.remoting.Operation(serviceControl, operationName);
				return remoteOperation;
			}
		}
		
		protected function prepareToken(actionName: String, onSuccessOrOptions:*, defaultParam: Object = null, defaultMethod: String = "GET"): AsyncToken{
			var config: ResourceConfig = null;
			var success: Function = null;
			var error: Function = null;
			var params: Array = defaultParam ? [defaultParam] : null;
			if (onSuccessOrOptions is Function)
				success = onSuccessOrOptions;
			else
				if  (onSuccessOrOptions is Object)
				{
					config = new ResourceConfig();
					ObjUtil.copyData(onSuccessOrOptions, config);
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
			var operation: AbstractOperation = createOperation(actionName, config, defaultParam, defaultMethod);
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

		public function AbstractResource(){}				

		public function set format(value: String): void{
			if (_format != value)
				serviceControl = createServiceControl(value);
			_format = value;
		}
						
		public function show(onSuccessOrOptions:*=null):AsyncToken
		{
			return prepareToken("show", onSuccessOrOptions);
		}
		
	}
}
