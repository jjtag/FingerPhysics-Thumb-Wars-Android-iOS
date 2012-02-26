package code.processor;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import code.BcClassDefinition;
import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcType;

import as2ObjC.ListWriteDestination;
import block.processors.LineProcessor;
import static block.RegexHelp.SPACE;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.PLUS;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.TIDENTIFIER;
import static block.RegexHelp.ANY;
import static block.RegexHelp.group;
import static block.RegexHelp.mb;
import static block.RegexHelp.or;

public class TopLevelProcessor extends LineProcessor
{
	private static Pattern interfacePattern = Pattern.compile("@interface" + SPACE + TIDENTIFIER + MBSPACE + ":" + MBSPACE + TIDENTIFIER + MBSPACE + mb("<" + ANY + ">"));
	private static Pattern typePattern = Pattern.compile(TIDENTIFIER);

	private static Pattern methodDef = Pattern.compile(group(or(PLUS, "-")) + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + MBSPACE + mb(":") + ANY + ";");
	private static Pattern paramDef = Pattern.compile(LPAR + ANY + RPAR + MBSPACE + IDENTIFIER);
	
	private BcClassDefinition lastBcClass;
	
	@Override
	public String process(String line)
	{
		Matcher m;
		
		if (lastBcClass != null)
		{
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
					System.out.println(params);
					m = paramDef.matcher(params);
					while (m.find())
					{
						traceGroups(m);
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
				ListWriteDestination dest = new ListWriteDestination();
				dest.writef("%s %s(%s);", returnType, methodName, paramsDest);
				
				
				return dest.toString();
			}
		}
		else
		{
			if ((m = interfacePattern.matcher(line)).find())
			{
				assert lastBcClass == null : lastBcClass.getName();
				
				String className = m.group(1);
				String extendsName = m.group(2);
				String interfaces = m.group(4);
				
				lastBcClass = new BcClassDefinition(className);
				
				StringBuilder result = new StringBuilder("public class " + className + " : public " + extendsName);				
				if (interfaces != null)
				{
					m = typePattern.matcher(interfaces);
					while (m.find())
					{
						result.append(", public " + m.group(1));					
					}
				}
				return result.toString();
			}
		}
		return line;
	}	
}
