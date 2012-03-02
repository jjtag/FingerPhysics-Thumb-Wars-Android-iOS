package block;

import static block.RegexHelp.ANY;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.PLUS;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.group;
import static block.RegexHelp.mb;
import static block.RegexHelp.or;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcType;

public class BcFunctionCapture
{
	private static Pattern methodDef = Pattern.compile(group(or(PLUS, "-")) + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + MBSPACE + mb(":") + ANY + ";");
	private static Pattern paramDef = Pattern.compile(LPAR + ANY + RPAR + MBSPACE + IDENTIFIER);
	private static Pattern paramProtocolType = Pattern.compile("<" + MBSPACE + IDENTIFIER + MBSPACE + ">");

	public static BcFuncDefinition tryCapture(String line)
	{
		Matcher m = methodDef.matcher(line);

		if (m.find())
		{
			boolean isStatic = m.group(1).equals("+");
			String returnType = m.group(2);
			String methodName = m.group(3);
			boolean hasParams = m.group(4) != null;

			BcFuncDefinition bcFunc = new BcFuncDefinition(methodName, new BcType(returnType));
			bcFunc.setStatic(isStatic);

			if (hasParams)
			{
				String params = m.group(5);
				m = paramDef.matcher(params);
				while (m.find())
				{
					String paramType = m.group(1);
					String paramName = m.group(2);

					Matcher matcher;
					if ((matcher = paramProtocolType.matcher(paramType)).find())
					{
						paramType = matcher.group(1) + "*";
					}

					bcFunc.addParam(new BcFuncParam(paramName, new BcType(paramType)));
				}
			}
			return bcFunc;
		}
		
		return null;
	}
}
