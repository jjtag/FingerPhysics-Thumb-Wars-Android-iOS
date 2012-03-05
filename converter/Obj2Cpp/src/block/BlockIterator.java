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

	public BlockIterator readCodeUntilToken(String token)
	{
		int storePos = position;
		
		BlockIterator iter = new BlockIterator();
		while (hasNext())
		{
			String line = next().trim();
			if (line.equals(token))
			{
				return iter;
			}
			iter.codeLines.add(line);
		}
		
		position = storePos;
		return null;
	}
	
	public BlockIterator readBlock()
	{
		BlockIterator iter = new BlockIterator();

		int bracketCounter = 0;
		int parenthesisCounter = 0;
		boolean inStringLiteral = false;		
		boolean inComment = false;
		boolean inSingleLineComment = false;
		
		StringBuilder lineBuffer = new StringBuilder();

		char prevChar = 0;
		char chr = 0;
		
		boolean blockCompleted = false;
		while (!blockCompleted)
		{
			inSingleLineComment = false;
			
			String codeLine = next();
			for (int i = 0; i < codeLine.length(); i++)
			{
				prevChar = chr;
				chr = codeLine.charAt(i);
				
				if (chr == '"' && prevChar != '\\')
				{
					inStringLiteral = !inStringLiteral;
				}
				
				if (inStringLiteral)
				{
					lineBuffer.append(chr);
					continue;
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
				
				if (inSingleLineComment || inComment)
				{
					lineBuffer.append(chr);
					continue;
				}
				
				if (chr == '(' || chr == '[')
				{
					bracketCounter++;
				}
				else if (chr == ')' || chr == ']')
				{
					assert bracketCounter > 0;
					bracketCounter--;
				}

				lineBuffer.append(chr);
				
				if (bracketCounter > 0)
				{
					continue;
				}
				
				if (chr == '{')
				{
					parenthesisCounter++;						
				}
				else if (chr == '}')
				{
					assert parenthesisCounter > 0;
					parenthesisCounter--;
					if (parenthesisCounter == 0)
					{
						blockCompleted = true;
						break;
					}
				}
			}
			
			iter.codeLines.add(lineBuffer.toString());
			lineBuffer.setLength(0);
		}
		
		iter.codeLines.remove(0);
		iter.codeLines.remove(iter.codeLines.size() - 1);
		
		return iter;
	}
}
