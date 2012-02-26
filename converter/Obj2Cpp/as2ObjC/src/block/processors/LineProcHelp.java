package block.processors;

import java.util.ArrayList;
import java.util.List;

public class LineProcHelp
{
	public static List<String> splitArgs(String line, char delim)
	{
		List<String> tokens = new ArrayList<String>();
		
		if (line.indexOf(delim) == -1)
		{
			tokens.add(line);
			return tokens;
		}
		
		int parCnt = 0; // parentnessis counter
		int braCnt = 0; // bracket counter
		
		char prevChar = 0;
		boolean inParentnessis = false;
		boolean inBracket = false;
		boolean inStrLiteral = false;
		
		StringBuilder tokenBuffer = new StringBuilder();
		
		for (int i = 0; i < line.length(); i++)
		{
			char chr = line.charAt(i);
			if (chr == '"' && prevChar != '\\')
			{
				inStrLiteral = !inStrLiteral;
			}
			prevChar = chr;
			
			if (inStrLiteral)
			{
				tokenBuffer.append(chr);
				continue;
			}
			
			if (chr == '(')
			{
				parCnt++;
				inParentnessis = true;
			}
			else if (chr == ')')
			{
				parCnt--;
				if (parCnt == 0)
				{
					inParentnessis = false;
				}
			}
			
			if (inParentnessis)
			{
				tokenBuffer.append(chr);
				continue;
			}
			
			if (chr == '[')
			{
				braCnt++;
				inBracket = true;
			}
			else if (chr == ']')
			{
				braCnt--;
				if (braCnt == 0)
				{
					inBracket = false;
				}
			}
			
			if (inBracket)
			{
				tokenBuffer.append(chr);
				continue;
			}
			
			else if (chr == delim)
			{
				tokens.add(tokenBuffer.toString().trim());
				tokenBuffer.setLength(0);
			}
			else
			{
				tokenBuffer.append(chr);
			}
		}
		
		if (tokenBuffer.length() > 0)
		{
			tokens.add(tokenBuffer.toString().trim());
		}
		
		return tokens;
	}
	
	public static String parenthesisVal(String line, int start)
	{
		if (line.indexOf('(') == -1 || line.indexOf(')') == -1)
		{
			return null;
		}
		
		StringBuilder result = new StringBuilder();
		
		int counter = 0;
		boolean inStringLiteral = false;
		char prevChar = 0;
		for (int i = start; i < line.length(); i++)
		{
			char chr = line.charAt(i);
			if (chr == '"' && prevChar != '\\')
			{
				inStringLiteral = !inStringLiteral;
			}
			
			if (chr == '(' && !inStringLiteral)
			{
				if (counter > 0)
				{
					result.append(chr);
				}
				counter++;
			}
			else if (chr == ')' && !inStringLiteral)
			{
				counter--;
				if (counter > 0)
				{
					result.append(chr);
				}
				else
				{
					break;
				}
			}
			else
			{
				result.append(chr);
			}
			prevChar = chr;
		}
		
		return result.toString();
	}
}
