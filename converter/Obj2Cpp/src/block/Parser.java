package block;

import java.util.List;
import java.util.regex.Matcher;

import as2ObjC.ListWriteDestination;

public abstract class Parser
{
	protected BlockIterator iter;
	protected ListWriteDestination dest;

	public Parser(BlockIterator iter)
	{
		this.iter = iter;
		dest = new ListWriteDestination();
	}

	public abstract void parse();
	
	public List<String> getCodeLines()
	{
		return dest.getLines();
	}
	
	protected boolean isComment(String line)
	{
		return line.trim().startsWith("//");
	}
	
	protected void debugTraceGroups(Matcher m)
	{
		for (int i = 1; i <= m.groupCount(); ++i)
		{
			System.out.println(i + ": " + m.group(i));
		}
	}
}