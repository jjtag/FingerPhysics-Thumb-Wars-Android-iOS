package block;

import static block.RegexHelp.SPACE;
import static block.RegexHelp.TIDENTIFIER;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import as2ObjC.WriteDestination;

public class ImplParser extends Parser
{
	private static Pattern implPattern = Pattern.compile("@implementation" + SPACE + TIDENTIFIER);

	public ImplParser(BlockIterator iter, WriteDestination dest)
	{
		super(iter, dest);
	}

	protected void process(String line)
	{
		Matcher m;

		if ((m = implPattern.matcher(line)).find())
		{
			String className = m.group(1);

			BlockIterator bodyIter = new BlockIterator();
			String bodyLine;
			while (!(bodyLine = iter.next()).equals("@end"))
			{
				bodyIter.add(bodyLine);
			}
			
			ClassBodyParser parser = new ClassBodyParser(bodyIter, dest, className);
			parser.parse();
		}
		else
		{
			dest.writeln(line);
		}
	}
}
