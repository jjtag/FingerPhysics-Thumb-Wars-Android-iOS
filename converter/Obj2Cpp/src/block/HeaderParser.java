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

import code.BcClassDefinition;
import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcPropertyDefinition;
import code.BcType;
import as2ObjC.CodeHelper;
import as2ObjC.ListWriteDestination;
import as2ObjC.WriteDestination;

public class HeaderParser extends Parser
{
	private static Pattern interfacePattern = Pattern.compile("@interface" + SPACE + TIDENTIFIER + mb(MBSPACE + ":" + MBSPACE + TIDENTIFIER + MBSPACE + mb("<" + ANY + ">")));
	private static Pattern typePattern = Pattern.compile(TIDENTIFIER);
	
	private static Pattern visiblityPattern = Pattern.compile("@" + group(or("public", "private", "protected")));

	private static Pattern methodDef = Pattern.compile(group(or(PLUS, "-")) + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + MBSPACE + mb(":") + ANY + ";");
	private static Pattern paramDef = Pattern.compile(LPAR + ANY + RPAR + MBSPACE + IDENTIFIER);

	private static Pattern propertyDef = Pattern.compile("@property" + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + ANY + ";");
	private static Pattern propertyEntry = Pattern.compile(mb(STAR) + MBSPACE + IDENTIFIER);
	private static Pattern protocolPropertyDef = Pattern.compile("@property" + MBSPACE + LPAR + ANY + RPAR + MBSPACE + "id" + MBSPACE + "<" + MBSPACE + IDENTIFIER + MBSPACE + mb(STAR) + MBSPACE + ">"+ MBSPACE + ANY + ";");
	private static Pattern modifierDef = Pattern.compile(group(or("assign", "retain", "copy", "readonly", "readwrite", "nonatomic", "atomic")));

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
			dest.writeln("public:");
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
			
			while (!(bodyLine = iter.next()).equals("@end"))
			{
				processClassBody(bodyLine);
			}
			dest.writeBlockClose(true);
			
			lastBcClass = null;
		}
		else
		{
			dest.writeln(line);
		}
	}

	private void processFieldsDef(String line)
	{
		Matcher m;
		if ((m = visiblityPattern.matcher(line)).find())
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
		
		if ((m = methodDef.matcher(line)).find())
		{
			boolean isStatic = m.group(1).equals("+");
			String returnType = m.group(2);
			String methodName = m.group(3);
			boolean hasParams = m.group(4) != null;

			BcFuncDefinition bcFunc = new BcFuncDefinition(methodName, new BcType(returnType));
			bcFunc.setStatic(isStatic);

			lastBcClass.addFunc(bcFunc);

			ListWriteDestination paramsDest = new ListWriteDestination();
			if (hasParams)
			{
				String params = m.group(5);
				m = paramDef.matcher(params);
				while (m.find())
				{
					String paramType = m.group(1);
					String paramName = m.group(2);

					bcFunc.addParam(new BcFuncParam(paramName, new BcType(paramType)));
				}

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
			}
			dest.writelnf("%s %s(%s);", returnType, methodName, paramsDest);
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
			
			if (m.group(3) == null)
			{
				debugTraceGroups(m);
			}
			
			String entriesString = m.group(3).trim();
			
			writeProperties(typeName, entriesString, modifiersString);
		}
		else
		{
			dest.writeln(line);
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
