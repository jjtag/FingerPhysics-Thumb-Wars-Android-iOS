package block.processors;

import static block.RegexHelp.QUOTE;

public class StringLiteralProcessor extends LineProcessor
{
	private static final String stringMark = "@" + QUOTE;
	
	@Override
	public String process(String line)
	{
		if (line.contains(stringMark))
		{
			return line.replace(stringMark, QUOTE);
		}
		return line;
	}

}
