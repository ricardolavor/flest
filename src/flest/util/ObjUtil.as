package flest.util
{
	import flash.utils.getQualifiedClassName;

	public class ObjUtil
	{
		public static function copyData(source: Object, dest: Object): void{
			for(var prop: * in dest)
				if (source[prop])
					dest[prop] = source[prop];
		}
		
		public static function getClassName(obj: Object): String{
			return getQualifiedClassName(obj).split("::").pop();
		}
	}
}