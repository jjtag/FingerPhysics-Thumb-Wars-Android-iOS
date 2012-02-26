package block.processors;

import static block.RegexHelp.DOT;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.SPACE;
import static block.RegexHelp.group;
import static block.RegexHelp.mb;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import as2ObjC.CodeHelper;

public class FunctionCallProcessor extends LineProcessor
{
	private static final String MBNEW = mb("new" + SPACE);

	private Pattern pattern = Pattern.compile(group(mb(DOT) + MBNEW + IDENTIFIER + MBSPACE + LPAR));

	private static final int GR_DOT = 2;
	private static final int GR_NEW = 3;
	private static final int GR_IDENTIFIER = 4;

	private static final String separators = "()[]\b\f\t\n\r|&^+-*/!%=~\\?<>:;{}&@#`\"";

	private List<String> types;
	
	public FunctionCallProcessor() 
	{
		types = new ArrayList<String>();
	}
	
	@Override
	public String process(String line)
	{
		
		Matcher matcher = pattern.matcher(line); 
		while (matcher.find())
		{
			String identifier = matcher.group(GR_IDENTIFIER);
			if (isIdentifierIgnored(identifier))
			{
				continue;
			}

			boolean isConstructor = matcher.group(GR_NEW) != null;
			boolean hasCallTarget = matcher.group(GR_DOT) != null;
			
			String argsStr = LineProcHelp.parenthesisVal(line, matcher.end() - 1);
			
			StringBuilder argsBuf = new StringBuilder();
			int argsCount = 0;
			if (argsStr.length() > 0)
			{
				List<String> args = LineProcHelp.splitArgs(argsStr, ',');
				argsCount = args.size();
				int argIndex = 0;
				for (String arg : args)
				{
					argsBuf.append(":");
					argsBuf.append(packArg(arg));
					if (++argIndex < args.size())
					{
						argsBuf.append(" ");
					}
				}
			}
			
			String oldCode;
			String newCode;
			
			if (isConstructor)
			{
				oldCode = line.substring(matcher.start(), matcher.end() + argsStr.length() + 1);
				newCode = createCall("[" + identifier + " alloc]", "init", argsBuf.toString());
				if (!types.contains(identifier))
				{
					types.add(identifier);
				}
			}
			else if (hasCallTarget)
			{
				int targetStart = findTargetStart(line, matcher.start() - 1);
				String target = line.substring(targetStart, matcher.start()).trim();
				newCode = createCall(target, identifier, argsBuf.toString());
				oldCode = line.substring(targetStart, matcher.end() + argsStr.length() + 1);
			}
			else
			{
				if (identifier.equals("super"))
				{
					newCode = createCall("super", "init", argsBuf.toString());
				}
				else
				{
					if (argsCount == 1) // type casting?
					{
						if (CodeHelper.isBasicType(identifier) || CodeHelper.canBeType(identifier))
						{
							if (CodeHelper.canBeType(identifier) && !types.contains(identifier))
							{
								types.add(identifier);
							}
							newCode = String.format("((%s)(%s))", CodeHelper.type(identifier), argsStr);
						}
						else
						{
							newCode = createCall("self", identifier, argsBuf.toString());
						}
					}
					else
					{
						newCode = createCall("self", identifier, argsBuf.toString());
					}
				}
				oldCode = line.substring(matcher.start(), matcher.end() + argsStr.length() + 1);
			}
			line = line.replace(oldCode, newCode);
			matcher = pattern.matcher(line);
		}
		
		return line;
	}
	
	private Object packArg(String arg) 
	{
		for (int i = 0; i < arg.length(); i++) 
		{
			char chr = arg.charAt(i);
			if (separators.indexOf(chr) != -1)
			{
				return "(" + arg + ")";
			}
		}
		return arg;
	}

	private String createCall(String target, String message, String args)
	{
		String newCode = "[" + target + " " + message + args + "]";
		return newCode;
	}

	private int findTargetStart(String line, int endPos)
	{
		char startChar = line.charAt(endPos);
		if (startChar == ')') // deal with type casting?
		{
			int counter = 0;
			for (int i = endPos; i >= 0; --i)
			{
				char chr = line.charAt(i);
				if (chr == ')')
				{
					counter++;
				}
				else if (chr == '(')
				{
					counter--;
					if (counter == 0)
						return i;
				}
			}
		}
		else
		{
			int lastNonSpaceIndex = endPos;
			for (int i = endPos; i >= 0; --i)
			{
				char chr = line.charAt(i);
				
				if (separators.indexOf(chr) != -1)
				{
					return lastNonSpaceIndex;
				}
				
				if (chr != ' ')
				{
					lastNonSpaceIndex = i;
				}
			}
		}
		
		return 0;
	}

	private boolean isIdentifierIgnored(String identifier)
	{
		return CodeHelper.isFlowOperator(identifier) || CodeHelper.isSystemReserved(identifier);
	}
	
	public List<String> getTypes() 
	{
		return types;
	}
}
