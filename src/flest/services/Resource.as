package flest.services
{
	import flash.utils.getDefinitionByName;
	
	import flest.utils.ArrayUtil;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	import mx.utils.ObjectUtil;
	
	internal class Resource extends AbstractResource implements IResource
	{
		private function get lastObjectFromPath(): Object{
			var param: Object = null;
			if (pathObjs.length > 0)
				return pathObjs[pathObjs.length - 1];
			throw new Error("Object required");
		}
				
		public function index(onSuccessOrOptions: * = null):AsyncToken
		{
			return prepareToken("index", onSuccessOrOptions, mountURL(false, true));
		}
		
		public function create(onSuccessOrOptions: * = null):AsyncToken
		{
			return prepareToken("create", onSuccessOrOptions, mountURL(false, false), lastObjectFromPath, "POST");
		}
		
		public function destroy(onSuccessOrOptions: * = null):AsyncToken
		{
			throw new Error("implementation not found");
		}
		
		public function update(onSuccessOrOptions: * = null):AsyncToken
		{
			return prepareToken("update", onSuccessOrOptions, mountURL(true, true), lastObjectFromPath, "PUT");
		}
		
		public function show(id: int = 0, onSuccessOrOptions: * = null):AsyncToken
		{							
			var url: String = id > 0 ? mountURL(false, false) + "/" + id + media : mountURL(true, true);
			return prepareToken("show", onSuccessOrOptions, url);
		}						
				
	}
}