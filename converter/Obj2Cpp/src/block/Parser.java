package block;

import java.util.regex.Matcher;

import bc.converter.WriteDestination;

public abstract class Parser
{
	protected BlockIterator iter;
	protected WriteDestination dest;

	protected boolean preprocessingEnabled = true;
	
	public Parser(BlockIterator iter, WriteDestination dest)
	{
		this.iter = iter;
		this.dest = dest;
	}
	
	public void parse()
	{
		boolean inComment = false;
		char prevChar = 0;

		while (iter.hasNext())
		{
			boolean inSingleLineComment = false;

			String line = iter.next();
			for (int i = 0; i < line.length(); ++i)
			{
				char chr = line.charAt(i);
				if (chr == '/' && prevChar == '/')
				{
					inSingleLineComment = true;
					break;
				}
				else if (chr == '*' && prevChar == '/')
				{
					inComment = true;
				}
				else if (chr == '/' && prevChar == '*')
				{
					inComment = false;
				}

				prevChar = chr;
			}

			if (inSingleLineComment || inComment)
			{
				dest.writeln(line.trim());
			}
			else
			{
				if (preprocessingEnabled)
				{
					line = preprocess(line).trim();
				}
				process(line);
			}
		}
	}

	private String preprocess(String line)
	{
		int parentnessisCounter = 0;
		boolean inStringLiteral = false;

		char prevChar = 0;

		StringBuilder lineBuffer = new StringBuilder();

		while (true)
		{
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
				}
				else
				{
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
						return lineBuffer.toString();
					}

					if (chr == '{' || chr == '}')
					{
						if (i < line.length() - 1)
						{
							String restOfLine = line.substring(i + 1).trim();
							if (restOfLine.length() > 0)
							{
								iter.insert(restOfLine);
							}
						}
						
						if (lineBuffer.length() > 0)
						{
							String currentLine = lineBuffer.toString().trim();
							if (currentLine.length() > 0)
							{
								iter.insert(Character.toString(chr));
								return currentLine;
							}
						}
						return Character.toString(chr);
					}
					else
					{
						lineBuffer.append(chr);
					}
				}

				prevChar = chr;
			}

			if (parentnessisCounter == 0 && chr != ',')
			{
				return lineBuffer.toString();
			}

			line = iter.next();
		}
	}

	protected abstract void process(String line);

	protected String peek()
	{
		return iter.peek();
	}
	
	protected void debugTraceGroups(Matcher m)
	{
		for (int i = 0; i <= m.groupCount(); ++i)
		{
			System.out.println(i + ": " + m.group(i));
		}
	}
}