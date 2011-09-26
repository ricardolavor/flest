package flest.service.filter
{
	import flash.net.getClassByAlias;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import flest.serialization.json.JSON;
	
	import mx.rpc.http.AbstractOperation;
	import mx.rpc.http.SerializationFilter;
	
	public class JSONFilter extends SerializationFilter
	{
		public function JSONFilter()
		{
			super();
		}
		
		private function objToModel(obj: Object): Object
		{
			for (var key: String in obj)
			{
				var value: Object = obj[key];
				var clazz: Class = getClassByAlias(key);
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
					break;
			}			
			return obj;
		}
		
		override public function deserializeResult(operation:AbstractOperation, result:Object):Object
		{
			var result: Object = JSON.decode(result.toString());
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