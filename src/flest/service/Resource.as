package flest.service
{
	import flash.utils.getDefinitionByName;
	
	import flest.util.ArrayUtil;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	
	internal class Resource extends AbstractResource implements IResource
	{
		private function get lastObjectFromPath(): Object{
			var param: Object = null;
			if (pathObjs.length > 0)
				return pathObjs[pathObjs.length - 1];
			throw new Error("Object required");
		}
				
		public function Resource(){}
								
		public function index(onSuccessOrOptions:*=null):AsyncToken
		{
			return prepareToken("index", onSuccessOrOptions, mountURL(false, true), null);
		}
		
		public function create(onSuccessOrOptions:*=null):AsyncToken
		{
			return prepareToken("create", onSuccessOrOptions, mountURL(false, false), lastObjectFromPath, "POST");
		}
		
		public function destroy(onSuccessOrOptions:*=null):AsyncToken
		{
			throw new Error("implementation not found");
		}
		
		public function update(onSuccessOrOptions:*=null):AsyncToken
		{
			throw new Error("implementation not found");
		}
				
	}
}