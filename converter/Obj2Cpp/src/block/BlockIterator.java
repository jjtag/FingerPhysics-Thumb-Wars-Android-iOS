package block;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class BlockIterator
{
	private List<String> codeLines;
	private int position;

	private BlockIterator()
	{
		position = -1;
		codeLines = new ArrayList<String>();
	}

	public BlockIterator(List<String> lines)
	{
		position = -1;
		codeLines = processLines(lines);
	}

	public boolean hasNext()
	{
		return position < codeLines.size() - 1;
	}

	public String next()
	{
		return codeLines.get(++position);
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
			
			iter.codeLines.add(lineBuffer.toString());
		}
		
		iter.codeLines.remove(0);
		iter.codeLines.remove(iter.codeLines.size() - 1);
		
		return iter;
	}

	private List<String> processLines(List<String> lines)
	{
		List<String> codeLines = new ArrayList<String>();

		int parentnessisCounter = 0;
		boolean inStringLiteral = false;
		boolean inComment = false;

		char prevChar = 0;
		
		Iterator<String> iter = lines.iterator();
		StringBuilder lineBuffer = new StringBuilder();
		
		while (iter.hasNext())
		{
			boolean inSingleLineComment = false;
			
			String line = iter.next().trim();
			if (line.length() == 0)
			{
				codeLines.add(line);
				continue;
			}
			
			char chr = 0;
			for (int i = 0; i < line.length(); i++)
			{
				chr = line.charAt(i);
				
				// strings
				if (chr == '"' && prevChar != '\\')
				{
					inStringLiteral = !inStringLiteral;
				}
				
				if (inStringLiteral)
				{
					lineBuffer.append(chr);
					continue;
				}
				
				// multiline comment
				if (chr == '*' && prevChar == '/')
				{
					inComment = true;
				}
				else if (chr == '/' && prevChar == '*')
				{
					inComment = false;
				}
				
				if (inComment)
				{
					lineBuffer.append(chr);
					continue;
				}
				
				// single line comment				
				else if (chr == '/' && prevChar == '/')
				{
					inSingleLineComment = true;
				}
				
				if (inSingleLineComment)
				{
					lineBuffer.append(chr);
					continue;
				}
				
				if (chr == '(' || chr == '[')
				{
					parentnessisCounter++;
				}
				else if (chr == ')' || chr == ']')
				{
					assert parentnessisCounter > 0;
					parentnessisCounter--;
				}

				if ((chr == ';' && parentnessisCounter == 0))
				{
					lineBuffer.append(chr);
					flushBuffer(codeLines, lineBuffer);
					continue;
				}
				
				if (chr == '{' || chr == '}')
				{
					flushBuffer(codeLines, lineBuffer);					
					codeLines.add(Character.toString(chr));
				}
				else
				{
					lineBuffer.append(chr);				
				}
				
				prevChar = chr;
			}
			
			if ((inComment || inSingleLineComment || parentnessisCounter == 0) && chr != ',')
			{
				flushBuffer(codeLines, lineBuffer);
			}
		}
		
		return codeLines;
	}

	private void flushBuffer(List<String> codeLines, StringBuilder buffer)
	{
		String line = buffer.toString().trim();
		if (line.length() > 0)
		{
			codeLines.add(line);
		}
		buffer.setLength(0);
	}
}
