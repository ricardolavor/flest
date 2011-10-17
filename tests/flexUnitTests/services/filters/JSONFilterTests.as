package flexUnitTests.services.filters
{
	import avmplus.getQualifiedClassName;
	
	import flest.services.filters.JSONFilter;
	import flest.utils.ObjUtil;
	import flest.utils.StringUtil;
	
	import flexUnitTests.models.Car;
	
	import flexunit.framework.Assert;
	
	import mx.rpc.http.AbstractOperation;
	
	public class JSONFilterTests
	{	
		private var filter: JSONFilter;
		
		[Before]
		public function setUp():void
		{
			filter = new JSONFilter();
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{			
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		private function carJson(model: String, manYear: int): String
		{
			return StringUtil.substitute("{\"car\":{\"model\": \"{0}\", \"manufacturing_year\":\"{1}\"}}", model, manYear);
		}
		
		[Test]
		public function testDeserializeResultIgnoringClassName():void
		{			
			var model: String = "Ferrari";
			var manYear: int = 2011;
			var json: String = carJson(model, manYear);
			var fakeOperation: AbstractOperation = new AbstractOperation();
			filter.defineJSONIgnoreClassNameForOperation(fakeOperation, true);
			var obj: Object = filter.deserializeResult(fakeOperation, json);
			Assert.assertNotNull(obj.car);
			Assert.assertEquals(model, obj.car.model);
			Assert.assertEquals(manYear, obj.car.manufacturing_year);
		}
		
		[Test]
		public function testDeserializeResult():void
		{
			var model: String = "Ferrari";
			var manYear: int = 2011;
			var json: String = carJson(model, manYear);
			var fakeOperation: AbstractOperation = new AbstractOperation();
			var car: Car = filter.deserializeResult(fakeOperation, json) as Car;
			Assert.assertNotNull(car);
			Assert.assertEquals(model, car.model);
			Assert.assertEquals(manYear, car.manufacturingYear);
		}		
		
		[Test]
		public function testSerializeParametersWithPostMethod():void
		{
			var fakeOperation: AbstractOperation = new AbstractOperation();
			fakeOperation.method = "POST";		
			fakeOperation.argumentNames = ["param1"];
			var json: Object = filter.serializeParameters(fakeOperation, [[{name: "jhon", id: 10}]]);
			Assert.assertTrue(json is String);
			Assert.assertEquals("{\"param1\":{\"name\":\"jhon\",\"id\":10}}", json.toString());
		}
		
		[Test]
		public function testSerializeParametersWithNonPostMethod(): void
		{
			var fakeOperation: AbstractOperation = new AbstractOperation();
			fakeOperation.method = "GET";		
			fakeOperation.argumentNames = ["param1"];
			var obj: Object = filter.serializeParameters(fakeOperation, [[{name: "jhon", id: 10}]]);
			Assert.assertNotNull(obj.param1);
			Assert.assertEquals("jhon", obj.param1.name);
			Assert.assertEquals(10, obj.param1.id);
		}
	}
}