package block;

import static block.RegexHelp.ANY;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.PLUS;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.SPACE;
import static block.RegexHelp.STAR;
import static block.RegexHelp.TIDENTIFIER;
import static block.RegexHelp.group;
import static block.RegexHelp.mb;
import static block.RegexHelp.or;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import as2ObjC.CodeHelper;
import as2ObjC.ListWriteDestination;
import as2ObjC.WriteDestination;
import code.BcClassDefinition;
import code.BcFieldDefinition;
import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcPropertyDefinition;
import code.BcType;

public class HeaderParser extends Parser
{
	private static Pattern interfacePattern = Pattern.compile("@interface" + SPACE + TIDENTIFIER + mb(MBSPACE + ":" + MBSPACE + TIDENTIFIER + MBSPACE + mb("<" + ANY + ">")));
	private static Pattern typePattern = Pattern.compile(TIDENTIFIER);
	
	private static Pattern fieldPattern = Pattern.compile(IDENTIFIER + MBSPACE + ANY + ";");
	private static Pattern fieldProtocolPattern = Pattern.compile(group("id" + MBSPACE + "<" + MBSPACE + IDENTIFIER + MBSPACE + ">") + MBSPACE + ANY + ";");
	private static Pattern fieldEntry = Pattern.compile(mb(STAR) + MBSPACE + IDENTIFIER);
	
	private static Pattern visiblityPattern = Pattern.compile("@" + group(or("public", "private", "protected")));

	private static Pattern methodDef = Pattern.compile(group(or(PLUS, "-")) + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + MBSPACE + mb(":") + ANY + ";");
	private static Pattern paramDef = Pattern.compile(LPAR + ANY + RPAR + MBSPACE + IDENTIFIER);
	private static Pattern paramProtocolType = Pattern.compile("<" + MBSPACE + IDENTIFIER + MBSPACE + ">");

	private static Pattern propertyDef = Pattern.compile("@property" + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + ANY + ";");
	private static Pattern propertyEntry = Pattern.compile(mb(STAR) + MBSPACE + IDENTIFIER);
	private static Pattern protocolPropertyDef = Pattern.compile("@property" + MBSPACE + LPAR + ANY + RPAR + MBSPACE + "id" + MBSPACE + "<" + MBSPACE + IDENTIFIER + MBSPACE + mb(STAR) + MBSPACE + ">"+ MBSPACE + ANY + ";");
	private static Pattern modifierDef = Pattern.compile(group(or("assign", "retain", "copy", "readonly", "readwrite", "nonatomic", "atomic")));
	
	private static Pattern protocolPattern = Pattern.compile("@protocol" + SPACE + TIDENTIFIER);

	private BcClassDefinition lastBcClass;
	private Map<String, BcClassDefinition> bcClasses;

	public HeaderParser(BlockIterator iter, WriteDestination dest, Map<String, BcClassDefinition> bcClasses)
	{
		super(iter, dest);
		this.bcClasses = bcClasses;
	}

	public void process(String line)
	{
		Matcher m;

		if ((m = interfacePattern.matcher(line)).find())
		{
			assert lastBcClass == null : lastBcClass.getName();

			String className = m.group(1);
			String extendsName = m.group(3) == null ? "NSObject" : m.group(3);
			String interfaces = m.group(5);

			assert !bcClasses.containsKey(className);
			lastBcClass = new BcClassDefinition(className);
			lastBcClass.setExtendsName(extendsName);
			bcClasses.put(className, lastBcClass);

			dest.write("class " + className + " : public " + extendsName);
			if (interfaces != null)
			{
				m = typePattern.matcher(interfaces);
				while (m.find())
				{
					dest.write(", public " + m.group(1));
				}
			}
			dest.writeln();
			dest.writeBlockOpen();

			dest.decTab();
			dest.writeln("private:");
			dest.incTab();
			
			String bodyLine;
			bodyLine = iter.next();
			if (bodyLine.equals("{"))
			{
				while (!(bodyLine = iter.next()).equals("}"))
				{
					processFieldsDef(bodyLine);
				}
			}
			else
			{
				iter.pushBack();
			}
			
			dest.writeln();
			dest.decTab();
			dest.writeln("public:");
			dest.incTab();
			
			while (!(bodyLine = iter.next()).equals("@end"))
			{
				processClassBody(bodyLine);
			}
			dest.writeBlockClose(true);
			
			lastBcClass = null;
		}
		else if ((m = protocolPattern.matcher(line)).find())
		{
			String name = m.group(1);
			dest.writelnf("class %s", name);
			dest.writeBlockOpen();
			
			dest.decTab();
			dest.writeln("public:");
			dest.incTab();
			
			BlockIterator bodyIter = new BlockIterator();
			String bodyLine;
			while (!(bodyLine = iter.next()).equals("@end"))
			{
				bodyIter.add(bodyLine);
			}
			
			new ProtocolParser(bodyIter, dest).parse();
			
			dest.writeBlockClose(true);
		}
		else
		{
			dest.writeln(line);
		}
	}

	private void processFieldsDef(String line)
	{
		Matcher m;
		if ((m = fieldProtocolPattern.matcher(line)).find())
		{
			String typeName = m.group(2) + "*";
			String entriesStr = m.group(1);
			
			addFields(typeName, entriesStr);
			
			dest.writeln(line.replace(m.group(1), typeName));
		}
		else if ((m = fieldPattern.matcher(line)).find())
		{
			String typeName = m.group(1);
			String entriesStr = m.group(2);
			
			addFields(typeName, entriesStr);
			
			dest.writeln(line);
		}
		else if ((m = visiblityPattern.matcher(line)).find())
		{
			String modifier = m.group(1);
			dest.decTab();
			dest.writeln(m.replaceFirst(modifier + ":"));
			dest.incTab();
		}
		else
		{		
			dest.writeln(line);
		}
	}
	
	private void processClassBody(String line)
	{
		Matcher m;
		
		BcFuncDefinition bcFunc;
		if ((bcFunc = BcFunctionCapture.tryCapture(line)) != null)
		{
			lastBcClass.addFunc(bcFunc);

			ListWriteDestination paramsDest = new ListWriteDestination();
			List<BcFuncParam> funcParams = bcFunc.getParams();
			int index = 0;
			for (BcFuncParam param : funcParams)
			{
				paramsDest.writef("%s %s", param.getType().getName(), param.getName());
				if (++index < funcParams.size())
				{
					paramsDest.write(", ");
				}
			}
			dest.writelnf("virtual %s %s(%s);", bcFunc.getReturnType().getName(), bcFunc.getName(), paramsDest);
		}
		else if ((m = protocolPropertyDef.matcher(line)).find())
		{
			String modifiersString = m.group(1);
			String typeName = m.group(2) + (m.group(3) != null ? "*" : "");			
			String entriesString = m.group(4).trim();
			
			writeProperties(typeName, entriesString, modifiersString);
		}
		else if ((m = propertyDef.matcher(line)).find())
		{
			String modifiersString = m.group(1);
			String typeName = m.group(2);
			
			String entriesString = m.group(3).trim();
			
			writeProperties(typeName, entriesString, modifiersString);
		}
		else
		{
			dest.writeln(line);
		}
	}

	private void addFields(String typeName, String entriesStr)
	{
		Matcher matcher = fieldEntry.matcher(entriesStr);
		while (matcher.find())
		{
			boolean isReference = matcher.group(1) != null;
			String name = matcher.group(2);

			String type = typeName + (isReference ? "*" : "");
			
			BcFieldDefinition bcField = new BcFieldDefinition(name, new BcType(type));
			lastBcClass.addField(bcField);
		}
	}
	
	private void writeProperties(String typeName, String entriesStr, String modifiersStr)
	{
		Matcher matcher = modifierDef.matcher(modifiersStr);
		List<String> modifiers = new ArrayList<String>();
		while (matcher.find())
		{
			modifiers.add(matcher.group(1));
		}
		
		matcher = propertyEntry.matcher(entriesStr);
		while (matcher.find())
		{
			boolean isReference = matcher.group(1) != null;
			String name = matcher.group(2);

			String type = typeName + (isReference ? "*" : "");
			
			BcPropertyDefinition bcProperty = new BcPropertyDefinition(name, new BcType(type));
			lastBcClass.addProperty(bcProperty);
			
			for (String modifier : modifiers)
			{
				bcProperty.setModifier(modifier);
			}
			
			String propType = CodeHelper.type(bcProperty.getType());
			String propName = CodeHelper.identifier(name);
			
			dest.writelnf("%s %s();", propType, propName);
			if (!bcProperty.isReadonly())
			{
				dest.writelnf("void set%s(%s __value);", Character.toUpperCase(propName.charAt(0)) + propName.substring(1), propType);
			}				
		}
	}
}
