package flest.service
{
	import mx.rpc.AsyncToken;

	public interface IResource
	{
		function show(onSuccessOrOptions:* = null): AsyncToken;
		function create(onSuccessOrOptions:* = null): AsyncToken;
		function destroy(onSuccessOrOptions:* = null): AsyncToken;
		function update(onSuccessOrOptions:* = null): AsyncToken;
		function action(name: String, onSuccessOrOptions:* = null): AsyncToken;		
		function index(onSuccessOrOptions:* = null): AsyncToken;
	}
}