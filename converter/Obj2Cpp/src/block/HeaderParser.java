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

	private static Pattern propertyDef = Pattern.compile("@property" + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + MBSPACE + mb(STAR) + MBSPACE + IDENTIFIER + MBSPACE + ";");
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
			String extendsName = m.group(3);
			String interfaces = m.group(5);

			lastBcClass = new BcClassDefinition(className);
			bcClasses.put(className, lastBcClass);

			dest.write("public class " + className + " : public " + (extendsName == null ? "NSObject" : extendsName));
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
		else if ((m = propertyDef.matcher(line)).find())
		{
			String modifiers = m.group(1);

			String type = m.group(2) + (m.group(3) != null ? "*" : "");
			String name = m.group(4);

			BcPropertyDefinition bcProperty = new BcPropertyDefinition(name, new BcType(type));
			lastBcClass.addProperty(bcProperty);
			
			m = modifierDef.matcher(modifiers);
			while (m.find())
			{
				bcProperty.setModifier(m.group(1));
			}

			String propType = CodeHelper.type(bcProperty.getType());
			String propName = CodeHelper.identifier(name);

			dest.writelnf("%s %s();", propType, propName);
			if (!bcProperty.isReadonly())
			{
				dest.writelnf("void set%s(%s __value);", Character.toUpperCase(propName.charAt(0)) + propName.substring(1), propType);
			}
		}
		else
		{
			dest.writeln(line);
		}
	}
}
