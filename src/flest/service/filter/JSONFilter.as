package flest.service.filter
{
	import mx.rpc.http.AbstractOperation;
	import mx.rpc.http.SerializationFilter;
	
	import flest.serialization.json.JSON;
	
	public class JSONFilter extends SerializationFilter
	{
		public function JSONFilter()
		{
			super();
		}
		
		override public function deserializeResult(operation:AbstractOperation, result:Object):Object
		{
			return JSON.decode(result.toString());
		}
		
		override public function serializeParameters(operation:AbstractOperation, params:Array):Object
		{
			if (operation.method == "POST")
				return JSON.encode(super.serializeParameters(operation, params[0]));
			return super.serializeParameters(operation, params[0]);
		}
		
	}
}