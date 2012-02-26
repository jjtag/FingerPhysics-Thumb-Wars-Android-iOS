package block.processors;

import java.util.regex.Matcher;

public abstract class LineProcessor
{
	public abstract String process(String line);
	
	protected void traceGroups(Matcher matcher)
	{
		for (int i = 1; i <= matcher.groupCount(); i++)
		{
			System.out.println(i + ": " + matcher.group(i));
		}
	}
}
