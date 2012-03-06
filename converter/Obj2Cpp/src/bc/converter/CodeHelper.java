package bc.converter;

import code.BcType;

public class CodeHelper
{
	public static String type(String type)
	{
		return type;
	}

	public static String type(BcType type)
	{
		return type.getName();
	}
	
	public static String identifier(String name) 
	{
		return name;
	}
	
	public static String typeDefault(String type)
	{
		if (type.equals("void"))
		{
			return null;
		}
		
		if (type.contains("*") && type.equals("id"))
		{
			return "nil";
		}
		
		if (type.equals("BOOL"))
		{
			return "false";
		}
		
		return "0";
	}
}
