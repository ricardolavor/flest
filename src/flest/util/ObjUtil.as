package flest.util
{
	import flash.sampler.getMemberNames;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;

	public class ObjUtil
	{		
		public static function getClassName(obj: Object): String{
			return getQualifiedClassName(obj).split("::").pop();
		}
		
		public static function getRemoteClassName(obj: Object): String{			
			var remoteName: String = describeType(obj).@alias;
			if (flest.util.StringUtil.stringHasValue(remoteName))
				return remoteName;
			return getClassName(obj);
		}
		
		public static function dynObjectHasOnlyOneProperty(dynObj: Object): Boolean{
			var i: int = 0;
			for(var propName: String in dynObj){
				i++;
				if (i > 1)
					break;
			}				
			return i == 1;
		}
		
		public static function isSimple(obj: Object): Boolean{
			return ObjectUtil.isSimple(obj);
		}
		
		public static function getClassNameInPlural(obj: Object): String{
			var m: XML = describeType(obj);
			var plural: XMLList = m..metadata.(@name == "Plural");
			if (plural.length() > 0)
				return plural.arg.(@key == "name").@value;
			return Inflector.pluralize(getClassName(obj));
		}
	}
}
