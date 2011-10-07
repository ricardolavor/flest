package flest.services
{
	import mx.rpc.AsyncToken;

	public interface IResource
	{
		function show(id: int = 0, onSuccessOrOptions: * = null): AsyncToken;
		function create(onSuccessOrOptions: * = null): AsyncToken;
		function destroy(onSuccessOrOptions: * = null): AsyncToken;
		function update(onSuccessOrOptions: * = null): AsyncToken;
		function action(name: String, onSuccessOrOptions: * = null): AsyncToken;		
		function index(onSuccessOrOptions: * = null): AsyncToken;
	}
}