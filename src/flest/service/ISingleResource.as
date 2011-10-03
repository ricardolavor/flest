package flest.service
{
	import mx.rpc.AsyncToken;

	public interface ISingleResource
	{
		function show(onSuccessOrOptions: * = null): AsyncToken;
		function create(obj: Object, onSuccessOrOptions: * = null): AsyncToken;
		function destroy(onSuccessOrOptions: * = null): AsyncToken;
		function update(obj: Object, onSuccessOrOptions: * = null): AsyncToken;
		function action(name: String, onSuccessOrOptions: * = null): AsyncToken;
	}
}