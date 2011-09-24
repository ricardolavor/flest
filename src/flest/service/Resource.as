package flest.service
{
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	
	internal class Resource extends AbstractResource implements IResource
	{
		public function Resource(){}
						
		public function action(name:String, onSuccessOrOptions:*=null):AsyncToken
		{
			return prepareToken(name, onSuccessOrOptions);
		}
		
		public function index(onSuccessOrOptions:*=null):AsyncToken
		{
			return prepareToken("index", onSuccessOrOptions);
		}
		
		public function create(onSuccessOrOptions:*=null):AsyncToken
		{
			var param: Object = null;
			for(var i: int = pathObjs.length - 1; i >= 0; i--)
				if (!(pathObjs[i] is String))
				{
					param = pathObjs[i];
					break;
				}
			return prepareToken("create", onSuccessOrOptions, param, "POST");
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