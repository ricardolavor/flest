package flexUnitTests.models
{
	[RemoteClass(alias="car")]
	[Plural(name="Cars")]
	public class Car
	{
		public var model: String;
		public var manufacturingYear: int;
	}
}