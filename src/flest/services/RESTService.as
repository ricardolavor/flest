package flest.services
{
	import flash.utils.Proxy;
	
	import mx.rpc.AbstractService;
	import mx.rpc.http.HTTPMultiService;
	import mx.rpc.http.mxml.HTTPMultiService;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	public class RESTService
	{

		public var format: String;
		public var baseURL: String;
		public var modelPackage: String;
		public var jsonIgnoreClassName: Boolean = false;
		
		private var _singleResource: SingleResource;
		private var _resource: Resource;

		public function RESTService(){}
										
		private function configureResource(resource: AbstractResource, pathObjs: Array): *{
			resource.baseURL = baseURL;			
			resource.pathObjs = pathObjs;
			resource.modelPackage = modelPackage;
			resource.format = format;	
			return resource;
		}
		
		public function resource(... args): IResource{
			if (!_resource)
				_resource = new Resource();
			return configureResource(_resource, args);
		}
		
		public function singleResource(... args): ISingleResource{
			if (!_singleResource)
				_singleResource = new SingleResource();
			return configureResource(_singleResource, args);
		}
	}
}