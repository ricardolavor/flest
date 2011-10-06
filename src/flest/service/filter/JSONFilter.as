package flest.service.filter
{
	import flash.net.getClassByAlias;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import flest.serialization.json.JSON;
	import flest.util.Inflector;
	import flest.util.ObjUtil;
	import flest.util.StringUtil;
	
	import mx.collections.ArrayList;
	import mx.rpc.http.AbstractOperation;
	import mx.rpc.http.SerializationFilter;
	
	public class JSONFilter extends SerializationFilter
	{
		private var unregisteredClasses: Dictionary;
		private var jsonIgnoreClassNamePerOperation: Dictionary = new Dictionary();
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
		
		private function adaptObjToASPattern(obj: Object): Object{
			var result: Object = new Object();
			for (var prop: String in obj)
				result[Inflector.camelize(prop)] = adaptObjToASPattern(obj[prop]);				
			return result;
		}
				
		private function objToModel(obj: Object): Object
		{
			if (ObjUtil.dynObjectHasOnlyOneProperty(obj))
				for (var key: String in obj)
				{
					var value: Object = obj[key];
					if (value == null || value is String || value is Number || value is Date || value is Array || value is XML || value is Boolean)
						break;
					var clazz: Class = getClassDefinition(key);
					var newObj: Object = null;
					if (clazz)
					{
						newObj = new clazz();
						var vars: XMLList = describeType(newObj)..accessor;
						for each(var variable: XML in vars)
						{
							var targetVarName: String = variable.@name;
							var sourceVarName: String = Inflector.underscore(variable.@name);
							if (value[sourceVarName])
								newObj[targetVarName] = value[sourceVarName];
						}
					}
					else
						newObj = adaptObjToASPattern(value);
					return newObj;
				}
			return adaptObjToASPattern(obj);
		}
		
		override public function deserializeResult(operation:AbstractOperation, result:Object):Object
		{
			var result: Object = JSON.decode(result.toString());
			if (jsonIgnoreClassNamePerOperation[operation])
			{
				delete jsonIgnoreClassNamePerOperation[operation];
				return result;
			}
			delete jsonIgnoreClassNamePerOperation[operation];
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
		
		public function defineJSONIgnoreClassNameForOperation(operation: AbstractOperation, value: Boolean): void{
			jsonIgnoreClassNamePerOperation[operation] = value;
		}
		
	}
}