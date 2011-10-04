package flest.service.filter
{
	import flash.net.getClassByAlias;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import flest.serialization.json.JSON;
	import flest.util.Inflector;
	import flest.util.StringUtil;
	
	import mx.collections.ArrayList;
	import mx.rpc.http.AbstractOperation;
	import mx.rpc.http.SerializationFilter;
	
	public class JSONFilter extends SerializationFilter
	{
		private var unregisteredClasses: Dictionary;
		public var modelPackage: String;

		public function JSONFilter()
		{
			super();
		}
		
		private function getClassDefinition(classNameOrAlias: String): Class{
			if (unregisteredClasses.hasOwnProperty(classNameOrAlias))
				return unregisteredClasses[classNameOrAlias] as Class;
			var clazz: Class = null;
			try
			{
				clazz = getClassByAlias(classNameOrAlias);
			} 
			catch(e: ReferenceError) 
			{
				try
				{
					var qualifiedName: String = StringUtil.stringHasValue(modelPackage) ? modelPackage + "::" : "";
					qualifiedName += Inflector.camelize(Inflector.ucfirst(classNameOrAlias));
					clazz = getDefinitionByName(qualifiedName) as Class;
					unregisteredClasses[classNameOrAlias] = clazz;
				}
				catch(e: ReferenceError)
				{
					unregisteredClasses[classNameOrAlias] = null;
				}
			}	
			return clazz;
		}
				
		private function objToModel(obj: Object): Object
		{
			if (obj is Dictionary)
			{
				for (var key: String in obj)
				{
					var value: Object = obj[key];
					var clazz: Class = getClassDefinition(key);					
					if (clazz)
					{
						var newObj: Object = new clazz();
						var vars: XMLList = describeType(newObj)..accessor;
						for each(var variable: XML in vars)
						{
							var varName: String = variable.@name; 
							if (value[varName])
								newObj[varName] = value[varName];
						}
						return newObj;
					}
					else
						return value;
				}
			}
			return obj;
		}
		
		override public function deserializeResult(operation:AbstractOperation, result:Object):Object
		{
			var result: Object = JSON.decode(result.toString());
			unregisteredClasses = new Dictionary();
			if (result is Array)
			{
				var newResult: Array = new Array();
				for each(var dic: Object in result)
					newResult.push(objToModel(dic));
				return newResult;
			}
			return objToModel(result);
		}
		
		override public function serializeParameters(operation:AbstractOperation, params:Array):Object
		{
			var serializedParams: Object = super.serializeParameters(operation, params[0]);
			if (operation.method == "POST")
				return JSON.encode(serializedParams);
			return serializedParams;
		}
		
	}
}