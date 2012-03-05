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
}
