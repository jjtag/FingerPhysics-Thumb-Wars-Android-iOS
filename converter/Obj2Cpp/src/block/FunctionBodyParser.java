package block;

import static block.RegexHelp.TIDENTIFIER;

import java.util.ArrayList;
import java.util.List;

import code.BcClassDefinition;

import as2ObjC.WriteDestination;

public class FunctionBodyParser extends Parser
{
	private BcClassDefinition bcClass;

	public FunctionBodyParser(BlockIterator iter, WriteDestination dest, BcClassDefinition bcClass)
	{
		super(iter, dest);
		this.bcClass = bcClass;
	}

	@Override
	protected void process(String line)
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
		String callLine;
		while ((callLine = getCallLine(line)) != null)
		{	
			String content = parseMethodCall(callLine);
			content = parseMethodCall(content);
			content = parseArguments(content);
			
			line = line.replace('[' + callLine + ']', content);
		}
		
		return line;
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
						String callLine = result.substring(0, result.length() - 1);
						if (isArrayCall(callLine))
						{
							result.setLength(0);
						}
						else
						{						
							return callLine;
						}
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

		boolean spaceFound = false;
		boolean insideString = false;
		int parentnessisCounter = 0;
		int bracketCounter = 0;
		char prevChar = 0;
		for (int i = 0; i < content.length(); ++i)
		{
			char chr = content.charAt(i);
			if (chr == '[')
			{
				bracketCounter++;
			}
			else if (chr == ']')
			{
				assert bracketCounter > 0;
				bracketCounter--;
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
			else if (chr == '"' && prevChar != '\\')
			{
				insideString = !insideString;
			}
			else if (spaceFound)
			{
				if (chr == '+' || chr == '-' || chr == '/' || chr == '*')
				{
					return true;
				}
				else if (chr != ' ')
				{
					return false;
				}
			}
			else if (chr == ' ')
			{
				spaceFound = bracketCounter == 0 && parentnessisCounter == 0 && !insideString;
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

		TokenIterator iter = new TokenIterator(str);
		
		String target = iter.captureUntilChar(str, ' ');
		String message = iter.captureUntilChar(str, ':');
		
		if (target.equals("super"))
		{
			target = bcClass.getExtendsName();
		}
		
		result.append(target);
		result.append(canBeType(target) ? staticCallMarker : "->");
		result.append(message);
		
		List<String> args = new ArrayList<String>();
		
		while (iter.canCapture())
		{
			String arg = iter.captureUntilChar(str, ' ');
			args.add(arg);
			
			if (iter.canCapture())
			{
				iter.captureUntilChar(str, ':'); // skip identifiers				
			}
		}
		
		result.append('(');
		int argIndex = 0;
		for (String arg : args)
		{
			result.append(arg);
			if (++argIndex < args.size())
			{
				result.append(',');
			}
		}
		
		result.append(')');
		
		return result.toString();
	}

	private static boolean canBeType(String str)
	{
		return str.matches(TIDENTIFIER);
	}
}
