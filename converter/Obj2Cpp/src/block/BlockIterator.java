package block;

import java.util.ArrayList;
import java.util.List;

public class BlockIterator
{
	private List<String> lines;
	private int position;

	private BlockIterator()
	{
		position = -1;
		lines = new ArrayList<String>();
	}

	public BlockIterator(String code)
	{
		position = -1;
		lines = spliteLines(code);
	}

	public boolean hasNext()
	{
		return position < lines.size() - 1;
	}

	public String next()
	{
		return lines.get(++position);
	}

	public void pushBack()
	{
		if (position > 0)
		{
			position--;
		}
	}

	public BlockIterator readBlock()
	{
		BlockIterator iter = new BlockIterator();

		int counter = 0;
		int parentnessis = 0;
		boolean inStringLiteral = false;
		boolean inParentnessis = false;
		boolean inComment = false;
		boolean inSingleLineComment = false;

		char prevChar = 0;
		boolean complete = false;
		while (!complete)
		{
			StringBuilder lineBuffer = new StringBuilder();
			inSingleLineComment = false;
			
			String codeLine = next();
			for (int i = 0; i < codeLine.length(); i++)
			{
				char chr = codeLine.charAt(i);
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
				if ((chr == '(' || chr == '[') && !inStringLiteral)
				{
					inParentnessis = true;
					counter++;
				}
				else if ((chr == ')' || chr == ']') && !inStringLiteral)
				{
					counter--;
					inParentnessis = counter > 0;
				}

				lineBuffer.append(chr);
				
				if (!inSingleLineComment && !inComment && !inParentnessis && !inStringLiteral)
				{
					if (chr == '{')
					{
						parentnessis++;						
					}
					else if (chr == '}')
					{
						parentnessis--;
						if (parentnessis == 0)
						{
							complete = true;
							break;
						}
					}
				}
				
				prevChar = chr;
			}
			
			iter.lines.add(lineBuffer.toString());
		}
		
		iter.lines.remove(0);
		iter.lines.remove(iter.lines.size() - 1);
		
		return iter;
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
			if ((chr == '(' || chr == '[') && !inStringLiteral)
			{
				inParentnessis = true;
				counter++;
			}
			else if ((chr == ')' || chr == ']') && !inStringLiteral)
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
				}
				else if (currentLine.startsWith("//"))
				{
					lines.add(currentLine);
					result.setLength(0);
				}
				else if (currentLine.endsWith(",") || currentLine.endsWith(":"))
				{
				}
				else
				{
					lines.add(currentLine);
					result.setLength(0);
				}
				continue;
			}

			if ((chr == ';' || chr == '{' || chr == '}') && !(inStringLiteral || inParentnessis) && !inSingleLineComment)
			{
				if (chr == ';')
				{
					result.append(chr);
				}

				String line = result.toString().trim();

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

		if (result.length() > 0)
		{
			lines.add(result.toString().trim());
		}

		return lines;
	}
}
