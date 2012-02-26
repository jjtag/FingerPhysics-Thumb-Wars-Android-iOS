package as2ObjC;

import static block.RegexHelp.DOT;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.TIDENTIFIER;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import code.BcType;

public class CodeHelper
{
	private static Pattern vectorPattern = Pattern.compile("Vector" + DOT + "<" + MBSPACE + IDENTIFIER + MBSPACE + ">");
	
	private static Map<String, String> basicTypesLookup;
	private static List<String> flowOperators;
	private static List<String> systemReserved;

	private static Pattern typePattern = Pattern.compile(TIDENTIFIER);
	
	private static List<String> basicTypes;
	
	static
	{
		basicTypes = new ArrayList<String>();
		basicTypes.add("int");
		basicTypes.add("uint");
		basicTypes.add("char");
		basicTypes.add("uchar");
		basicTypes.add("float");
		basicTypes.add("boolean");
		basicTypes.add("short");
		basicTypes.add("ushort");
		basicTypes.add("byte");
		basicTypes.add("ubyte");
		basicTypes.add("double");
		
		basicTypesLookup = new HashMap<String, String>();
		basicTypesLookup.put("void", "void");
		basicTypesLookup.put("int", "int");
		basicTypesLookup.put("float", "float");
		basicTypesLookup.put("double", "double");
		basicTypesLookup.put("Boolean", "BOOL");
		basicTypesLookup.put("Number", "float");
		basicTypesLookup.put("uint", "int");
		basicTypesLookup.put("String", "NSString*");
		basicTypesLookup.put("Object", "NSObject*");
		basicTypesLookup.put("Dictionary", "NSMutableDictionary*");
		basicTypesLookup.put("Function", "SEL");
		
		flowOperators = new ArrayList<String>();
		flowOperators.add("if");
		flowOperators.add("while");
		flowOperators.add("for");
		flowOperators.add("switch");
		flowOperators.add("do");
		flowOperators.add("each");
		flowOperators.add("return");
		
		systemReserved = new ArrayList<String>();
		systemReserved.add("trace");
		systemReserved.add("assert");
	}
	
	private static String findBasic(String type)
	{
		return basicTypesLookup.get(type);
	}
	
	public static boolean isFlowOperator(String identifier)
	{
		return flowOperators.contains(identifier);
	}
	
	public static boolean isSystemReserved(String identifier)
	{
		return systemReserved.contains(identifier);
	}
	
	public static boolean isBasicType(String type)
	{
		return basicTypes.contains(type);
	}
	
	public static String literal(String str)
	{
		return "\"" + str + "\"";
	}
	
//	public static String type(TextItem item)
//	{
//		return type(item.getText());
//	}
//
//	public static String typeImport(TextItem item)
//	{
//		return typeImport(item.getText());
//	}
	
	public static String typeImport(String type)
	{
		String basicType = findBasic(type);
		if (basicType != null || isVector(type))
		{
			return null;
		}
		
		return type;
	}
	
	public static String type(String type)
	{
		assert type != null;
		
		String basicType = findBasic(type);
		if (basicType != null)
		{
			return basicType;
		}
		
		if (isVector(type))
		{
			return "NSMutableArray*";
		}
		
		return type + "*";
	}

//	public static String identifier(TextItem item)
//	{
//		return identifier(item.getText());
//	}

	public static String type(BcType type)
	{
		return type.getName();
	}
	
	public static String identifier(String name) 
	{
		return name;
	}
	
	public static boolean canBeType(String type) 
	{
		return !isBasicType(type) && typePattern.matcher(type).matches();
	}
	
	public static void writeImport(WriteDestination dest, String name)
	{
		dest.writeln("#import " + literal(name + ".h"));
	}
	
//	public static void writeDeclaration(WriteDestination dest, DeclRecord record)
//	{
//		dest.write(CodeHelper.type(record.getType()) + " " + CodeHelper.identifier(record.getName()));
//	}
//	
//	public static void writeMethodParam(WriteDestination dest, DeclRecord record)
//	{
//		dest.write(":(" + CodeHelper.type(record.getType()) + ")" + CodeHelper.identifier(record.getName()));
//	}
	
	private static boolean isVector(String type) 
	{
		return vectorPattern.matcher(type).matches();
	}
}
