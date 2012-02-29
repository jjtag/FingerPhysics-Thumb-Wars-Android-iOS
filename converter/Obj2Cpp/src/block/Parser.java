package block;

import java.util.regex.Matcher;

import as2ObjC.WriteDestination;

public abstract class Parser
{
	protected BlockIterator iter;
	protected WriteDestination dest;

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
				dest.writeln(line);
			}
			else
			{
				process(line);
			}
		}
	}
	
	protected abstract void process(String line);

	protected void debugTraceGroups(Matcher m)
	{
		for (int i = 1; i <= m.groupCount(); ++i)
		{
			System.out.println(i + ": " + m.group(i));
		}
	}
}