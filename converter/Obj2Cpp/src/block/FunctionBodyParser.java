package block;

import static block.RegexHelp.ALL;
import static block.RegexHelp.ANY;
import static block.RegexHelp.DOT;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.RBRKT;
import static block.RegexHelp.STAR;
import static block.RegexHelp.PLUS;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.TIDENTIFIER;
import static block.RegexHelp.group;
import static block.RegexHelp.oneOff;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import bc.converter.WriteDestination;
import code.BcClassDefinition;
import code.BcPropertyDefinition;


public class FunctionBodyParser extends Parser
{
	private static Pattern propertySetPattern = Pattern.compile(ANY + DOT + group(MBSPACE + IDENTIFIER + MBSPACE + "=" + MBSPACE + ALL + MBSPACE) + ";");
	private static Pattern propertyGetPattern = Pattern.compile(ANY + group(DOT + MBSPACE + IDENTIFIER) + MBSPACE + oneOff(STAR, DOT, ",", ";", PLUS, "-", "/", RPAR, RBRKT));
	
	private static Pattern selfIfCallPattern = Pattern.compile("if" + MBSPACE + LPAR + group(MBSPACE + "self" + MBSPACE + "=" + MBSPACE + ALL + MBSPACE) + RPAR);
	private static Pattern selfCallPattern = Pattern.compile("self" + MBSPACE + "=" + MBSPACE + ANY);
	
	private static Set<String> propertiesNames = new HashSet<String>();
	
	private BcClassDefinition bcClass;

	public FunctionBodyParser(BlockIterator iter, WriteDestination dest, BcClassDefinition bcClass)
	{
		super(iter, dest);
		this.bcClass = bcClass;
	}

	public static void registerProperty(BcPropertyDefinition property)
	{
		propertiesNames.add(property.getName());
	}
	
	public static boolean hasRegisteredProperty(String name)
	{
		return propertiesNames.contains(name);
	}
	
	@Override
	protected void process(String line)
	{
		Matcher m;
		if ((m = propertySetPattern.matcher(line)).find())
		{
			String name = m.group(3);
			if (hasRegisteredProperty(name))
			{
				String setterName = "set" + Character.toUpperCase(name.charAt(0)) + name.substring(1);
				line = line.replace(m.group(2), String.format("%s(%s)", setterName, m.group(4)));
			}			
		}
		else
		{
			m = propertyGetPattern.matcher(line);
			while (m.find())
			{
				String name = m.group(3);
				if (hasRegisteredProperty(name))
				{
					line = line.replace(m.group(2), String.format(".%s()", name));
				}
			}
		}
		
		if (line.contains("[") && line.contains("]"))
		{
			String callLine = parseMethodCall(line).replace(staticCallMarker, "::");
			
			if ((m = selfIfCallPattern.matcher(callLine)).find())
			{
				callLine = callLine.replace(m.group(1), m.group(2));
			}
			else if ((m = selfCallPattern.matcher(callLine)).find())
			{
				callLine = m.replaceFirst(m.group(1));
			}
			
			dest.writeln(callLine);
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

		if (target.equals("self"))
		{
			// don't generate this->...
		}
		else
		{
			result.append(target);
			result.append(canBeType(target) ? staticCallMarker : "->");
		}
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
