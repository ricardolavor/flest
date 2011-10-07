package flest.services
{
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	
	internal class SingleResource extends AbstractResource implements ISingleResource
	{			
		public function create(obj: Object, onSuccessOrOptions:* = null): AsyncToken{
			return prepareToken("create", onSuccessOrOptions, mountURL(false, false), obj, "POST");	
		}
		
		public function destroy(onSuccessOrOptions: * = null): AsyncToken{
			throw new Error("implementation not found");			
		}		
		
		public function update(obj: Object, onSuccessOrOptions: * = null): AsyncToken{
			throw new Error("implementation not found");			
		}
		
		public function show(onSuccessOrOptions: * = null):AsyncToken
		{
			return prepareToken("show", onSuccessOrOptions, mountURL(true, true));
		}				
		
	}
}