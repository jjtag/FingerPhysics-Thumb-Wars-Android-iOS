package block;

import static block.RegexHelp.ALL;
import static block.RegexHelp.ANY;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.LBRKT;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.NOTSPACE;
import static block.RegexHelp.PLUS;
import static block.RegexHelp.RBRKT;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.SPACE;
import static block.RegexHelp.TIDENTIFIER;
import static block.RegexHelp.mb;
import static block.RegexHelp.group;
import static block.RegexHelp.few;
import static block.RegexHelp.or;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import as2ObjC.ListWriteDestination;
import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcType;

public class ImplParser extends Parser
{
	private static Pattern implPattern = Pattern.compile("@implementation" + SPACE + TIDENTIFIER);
	private static Pattern syntesizePattern = Pattern.compile("@synthesize" + SPACE + ANY + ";");

	private static Pattern methodDef = Pattern.compile(group(or(PLUS, "-")) + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + MBSPACE + mb(":") + ALL);
	private static Pattern paramDef = Pattern.compile(LPAR + ANY + RPAR + MBSPACE + IDENTIFIER);

	private static Pattern callPattern = Pattern.compile(LBRKT + ALL + RBRKT);
	private static Pattern arrayPattern = Pattern.compile(IDENTIFIER + MBSPACE + LBRKT + ALL + RBRKT);

	private static Pattern argumentPattern = Pattern.compile(group(NOTSPACE) + ":");

	private String implClass;

	public ImplParser(BlockIterator iter)
	{
		super(iter);
	}

	@Override
	public void parse()
	{
		while (iter.hasNext())
		{
			process(iter.next());
		}
	}

	private void process(String line)
	{
		Matcher m;

		if ((m = implPattern.matcher(line)).find())
		{
			assert implClass == null : implClass;

			implClass = m.group(1);

			String bodyLine;
			while (!(bodyLine = iter.next()).equals("@end"))
			{
				if (isComment(bodyLine))
				{
					dest.writeln(bodyLine);
				}
				else
				{
					processClassBody(bodyLine);
				}
			}
			implClass = null;
		}
		else
		{
			dest.writeln(line);
		}
	}

	private void processClassBody(String line)
	{
		Matcher m;
		if ((m = syntesizePattern.matcher(line)).find())
		{
			dest.writeln(line);
		}
		else if ((m = methodDef.matcher(line)).find())
		{
			String returnType = m.group(2);
			String methodName = m.group(3);
			boolean hasParams = m.group(4) != null;

			BcFuncDefinition bcFunc = new BcFuncDefinition(methodName, new BcType(returnType));

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
			dest.writelnf("%s %s::%s(%s)", returnType, implClass, methodName, paramsDest);
			dest.writeBlockOpen();
			BlockIterator bodyIter = iter.readBlock();
			while (bodyIter.hasNext())
			{
				String bodyLine = bodyIter.next();
				if (isComment(bodyLine))
				{
					dest.writeln(bodyLine);
				}
				else
				{
					processFuncBody(bodyLine);
				}
			}
			dest.writeBlockClose();
		}
		else
		{
			dest.writeln(line);
		}
	}

	private void processFuncBody(String line)
	{
		if (line.contains("[") && line.contains("]") && !arrayPattern.matcher(line).find())
		{
			String callLine = parseMethodCall(line);
			dest.writeln(callLine.replace("#", "::"));
		}
		else if (line.equals("{"))
		{
			dest.writeln(line);
			dest.incTab();
		}
		else if (line.equals("}"))
		{
			dest.decTab();
			dest.writeln(line);
		}
		else
		{
			dest.writeln(line);
		}
	}

	private String parseMethodCall(String line)
	{
		Matcher matcher = callPattern.matcher(line);
		if (matcher.find() && !arrayPattern.matcher(line).find())
		{
			int start = matcher.start();
			int end = matcher.end();

			StringBuilder result = new StringBuilder(line);
			String content = parseMethodCall(matcher.group(1));
			content = parseArguments(content);
			result.delete(start, end);
			result.insert(start, content);

			return result.toString();
		}
		else
		{
			return line;
		}
	}

	private String parseArguments(String str)
	{
		StringBuilder result = new StringBuilder();

		String paramsStr = str;
		Matcher matcher;
		boolean methodNameFound = false;
		while ((matcher = argumentPattern.matcher(paramsStr)).find())
		{
			int nameStart = matcher.start();
			int start = matcher.end();
			int end = matcher.find() ? matcher.start() : paramsStr.length();
			String paramValue = paramsStr.substring(start, end).trim();
			if (!methodNameFound)
			{
				result.append(str.substring(0, nameStart > 0 ? nameStart - 1 : nameStart));
				result.append("->");
				result.append(str.substring(nameStart, start - 1));

				result.append("(");

				result.append(paramValue);
				methodNameFound = true;
			}
			else
			{
				result.append(",");
				result.append(paramValue);
			}
			paramsStr = paramsStr.substring(end);
		}

		if (methodNameFound)
		{
			result.append(")");
			result.append(paramsStr);
		}
		else
		{
			int index = str.indexOf(" ");
			if (index == -1)
				return str;

			if ((str.charAt(0) == Character.toUpperCase(str.charAt(0))) && !str.contains("::"))
			{
				return str.substring(0, index) + "#" + str.substring(index + 1) + "()";
			}

			return str.substring(0, index) + "->" + str.substring(index + 1) + "()";
		}

		return result.toString();
	}

	private static boolean canBeType(String str)
	{
		return str.matches(TIDENTIFIER);
	}
}
