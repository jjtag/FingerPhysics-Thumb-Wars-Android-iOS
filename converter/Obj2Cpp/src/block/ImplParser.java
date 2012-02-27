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
		if (line.contains("[") && line.contains("]"))
		{
			String callLine = parseMethodCall(line);
			dest.writeln(callLine.replace(staticCallMarker, "::"));
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
		String callLine = getCallLine(line);
		if (callLine != null && !isArrayCall(callLine))
		{	
			String content = parseMethodCall(callLine);
			content = parseArguments(content);
			
			return line.replace('[' + callLine + ']', content);
		}
		else
		{
			return line;
		}
	}

	private String getCallLine(String line)
	{
		StringBuilder result = new StringBuilder();
		
		boolean insideString = false;
		int parentnessisCounter = 0;
		int bracketCounter = 0;
		char prevChar = 0;
		for (int i = 0; i < line.length(); ++i)
		{
			char chr = line.charAt(i);
			
			if (bracketCounter > 0)
			{
				result.append(chr);
			}
			
			if (chr == '"' && prevChar != '\\')
			{
				insideString = !insideString;
			}
			else if (!insideString)
			{			
				if (chr == '[')
				{
					bracketCounter++;
				}
				else if (chr == ']')
				{
					assert bracketCounter > 0;
					bracketCounter--;
					
					if (bracketCounter == 0)
					{
						result.deleteCharAt(result.length() - 1);
						return result.toString();
					}
				}
				else if (chr == '(')
				{
					parentnessisCounter++;
				}
				else if (chr == ')')
				{
					assert parentnessisCounter > 0;
					parentnessisCounter--;
				}
			}

			prevChar = chr;
		}

		return null;
	}

	private boolean isArrayCall(String line)
	{
		String content = line.trim();

		boolean insideString = false;
		int parentnessisCounter = 0;
		int bracketCounter = 0;
		char prevChar = 0;
		for (int i = 0; i < content.length(); ++i)
		{
			char chr = content.charAt(i);
			if (chr == '[')
				bracketCounter++;
			else if (chr == ']')
			{
				assert bracketCounter > 0;
				bracketCounter--;
			}
			else if (chr == '(')
				parentnessisCounter++;
			else if (chr == ')')
			{
				assert parentnessisCounter > 0;
				parentnessisCounter--;
			}
			else if (chr == '"' && prevChar != '\\')
				insideString = !insideString;
			else if (chr == ' ')
			{
				if (bracketCounter == 0 && parentnessisCounter == 0 && !insideString)
				{
					return false;
				}
			}

			prevChar = chr;
		}

		assert bracketCounter == 0 : bracketCounter;
		assert parentnessisCounter == 0 : parentnessisCounter;
		assert !insideString;

		return true;
	}

	private static String staticCallMarker = "__$static$__";

	private String parseArguments(String str)
	{
		StringBuilder result = new StringBuilder();

		String paramsStr = str;
		Matcher matcher;
		boolean argsFound = false;
		while ((matcher = argumentPattern.matcher(paramsStr)).find())
		{
			int nameStart = matcher.start();
			int start = matcher.end();
			int end = matcher.find() ? matcher.start() : paramsStr.length();
			String paramValue = paramsStr.substring(start, end).trim();
			if (!argsFound)
			{
				String target = str.substring(0, nameStart > 0 ? nameStart - 1 : nameStart);
				String message = str.substring(nameStart, start - 1);

				result.append(target);
				result.append(canBeType(target) ? staticCallMarker : "->");
				result.append(message);

				result.append("(");

				result.append(paramValue);
				argsFound = true;
			}
			else
			{
				result.append(",");
				result.append(paramValue);
			}
			paramsStr = paramsStr.substring(end);
		}

		if (argsFound)
		{
			result.append(")");
			result.append(paramsStr);
		}
		else
		{
			int index = str.indexOf(" ");
			if (index == -1)
				return str;

			String target = str.substring(0, index);
			String message = str.substring(index + 1);

			result.append(target);
			result.append(canBeType(target) ? staticCallMarker : "->");
			result.append(message);
			result.append("()");
		}

		return result.toString();
	}

	private static boolean canBeType(String str)
	{
		return str.matches(TIDENTIFIER);
	}
}
