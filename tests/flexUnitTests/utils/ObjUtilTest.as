package flexUnitTests.utils
{
	import flest.utils.ObjUtil;
	
	import flexunit.framework.Assert;
	import flexUnitTests.models.Car;
	
	public class ObjUtilTest
	{				
		[Test]
		public function testDynObjectHasOnlyOneProperty():void
		{
			var obj: Object = {prop1: "prop1"};
			Assert.assertTrue(ObjUtil.dynObjectHasOnlyOneProperty(obj));
			obj.prop2 = "prop2";
			Assert.assertFalse(ObjUtil.dynObjectHasOnlyOneProperty(obj));
		}
		
		[Test]
		public function testGetClassName():void
		{
			Assert.assertEquals("Car", ObjUtil.getClassName(Car));
		}
		
		[Test]
		public function testGetClassNameInPlural():void
		{
			Assert.assertEquals("Cars", ObjUtil.getClassNameInPlural(Car));
		}
		
		[Test]
		public function testGetRemoteClassName():void
		{
			Assert.assertEquals("car", ObjUtil.getRemoteClassName(Car));
		}
		
		[Test]
		public function testIsSimple():void
		{
			Assert.assertTrue(ObjUtil.isSimple(10));
			Assert.assertTrue(ObjUtil.isSimple("100"));
			Assert.assertTrue(ObjUtil.isSimple(new Date()));
			Assert.assertTrue(ObjUtil.isSimple(true));
			Assert.assertFalse(ObjUtil.isSimple(new Object()));
			Assert.assertFalse(ObjUtil.isSimple(new Car()));
		}
	}
}