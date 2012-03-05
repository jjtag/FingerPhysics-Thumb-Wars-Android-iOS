package block;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class BlockIterator
{
	private List<String> codeLines;
	private int position;

	public BlockIterator()
	{
		position = -1;
		codeLines = new ArrayList<String>();
	}

	public BlockIterator(List<String> lines)
	{
		position = -1;
		codeLines = lines;
	}

	public boolean hasNext()
	{
		return position < codeLines.size() - 1;
	}

	public String next()
	{
		return codeLines.get(++position);
	}
	
	public String peek()
	{
		if (hasNext())
		{
			return codeLines.get(position + 1);
		}
		
		return null;
	}
	
	public void add(String line)
	{
		codeLines.add(line);
	}
	
	public void insert(String line)
	{
		codeLines.add(position + 1, line);
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
}
