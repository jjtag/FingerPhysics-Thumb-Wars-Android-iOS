package block;

import java.util.ArrayList;
import java.util.List;

public class BlockIterator
{
	private List<String> lines;
	private int position;
	
	public BlockIterator(String code)
	{
		lines = spliteLines(code);
		position = -1;
	}
	
	public boolean hasNext()
	{
		return position < lines.size() - 1;
	}
	
	public String next()
	{
		return lines.get(++position);
	}

	private List<String> spliteLines(String code)
	{
		List<String> lines = new ArrayList<String>();
		
		StringBuilder result = new StringBuilder();
		
		int counter = 0;
		boolean inStringLiteral = false;
		boolean inParentnessis = false;
		boolean inComment = false;
		boolean inSingleLineComment = false;
		
		char prevChar = 0;
		for (int i = 0; i < code.length(); i++)
		{
			char chr = code.charAt(i);
			if (chr == '"' && prevChar != '\\')
			{
				inStringLiteral = !inStringLiteral;
			}
			if (chr == '*' && prevChar == '/')
			{
				inComment = true;
			}
			else if (chr == '/' && prevChar == '/')
			{
				inSingleLineComment = true;
			}
			else if (chr == '/' && prevChar == '*')
			{
				inComment = false;
			}
			if (chr == '(' && !inStringLiteral)
			{
				inParentnessis = true;
				counter++;
			}
			else if (chr == ')' && !inStringLiteral)
			{
				counter--;
				inParentnessis = counter > 0;
			}
			
			if ((chr == '\t' || chr == '\r') && !inComment)
			{
				continue;
			}
			
			if (chr == '\n' && inSingleLineComment)
			{
				inSingleLineComment = false;
			}
			if (chr == '\n' && !inComment)
			{	
				String currentLine = result.toString().trim();
				if (currentLine.length() == 0)
				{
					result.setLength(0);
					continue;
				}
				else if (currentLine.startsWith("//"))
				{
					lines.add(currentLine);
					result.setLength(0);
					continue;
				}
				else if (currentLine.endsWith(",") || currentLine.endsWith(":"))
				{
					continue;
				}
			}
			
			if ((chr == ';' || chr == '{' || chr == '}') && !(inStringLiteral || inParentnessis) && !inSingleLineComment)
			{
				if (chr == ';')
				{
					result.append(chr);
				}
				
				String line = result.toString().trim();
				
//				if (isSingleLineOperator(line))
//				{
//					if (line.contains("\n"))
//					{
//						String[] split = line.split("\n");
//						int lineIndex = 0;
//						for (String s : split) 
//						{
//							lines.add(++lineIndex > 1 ? ("\t" + s) : s);
//						}
//					}
//					else
//					{
//						lines.add(line);
//					}
//				}
//				else if (isCaseSwitch(line) || isDefaultSwitch(line))
//				{
//					if (line.contains("\n"))
//					{
//						String[] split = line.split("\n");
//						for (String s : split) 
//						{
//							lines.add(s);
//						}
//					}
//					else
//					{
//						lines.add(line);
//					}
//				}
				if (line.length() > 0)
				{				
					lines.add(line);
				}
				if (chr != ';')
				{
					lines.add("" + chr);
				}
				result.setLength(0);
			}
			else
			{
				result.append(chr);
			}
			prevChar = chr;
		}
		
		return lines;
	}

	private boolean isSingleLineOperator(String line) 
	{
		if (line.endsWith("{"))
			return false;
		
		return 	line.startsWith("if(") || line.startsWith("if ") ||
				line.startsWith("for(") || line.startsWith("for ") ||
				line.startsWith("while(") || line.startsWith("while ") ||
				line.equals("do");
	}
	
	private boolean isCaseSwitch(String line) 
	{
		return 	line.startsWith("case ");
	}
	
	private boolean isDefaultSwitch(String line) 
	{
		return 	line.startsWith("default:");
	}
}
