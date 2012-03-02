package block;

import static block.RegexHelp.SPACE;
import static block.RegexHelp.TIDENTIFIER;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import as2ObjC.WriteDestination;
import code.BcClassDefinition;

public class ImplParser extends Parser
{
	private static Pattern implPattern = Pattern.compile("@implementation" + SPACE + TIDENTIFIER);

	private Map<String, BcClassDefinition> bcClasses;
	
	public ImplParser(BlockIterator iter, WriteDestination dest, Map<String, BcClassDefinition> bcClasses)
	{
		super(iter, dest);
		this.bcClasses = bcClasses;
	}

	protected void process(String line)
	{
		Matcher m;

		if ((m = implPattern.matcher(line)).find())
		{
			String className = m.group(1);
			BcClassDefinition bcClass = bcClasses.get(className);
			assert bcClass != null : className;		

			BlockIterator bodyIter = new BlockIterator();
			String bodyLine;
			while (!(bodyLine = iter.next()).equals("@end"))
			{
				bodyIter.add(bodyLine);
			}
			
			ClassBodyImplParser parser = new ClassBodyImplParser(bodyIter, dest, bcClass);
			parser.parse();
		}
		else if (line.contains("@interface"))
		{
			assert false : line;
		}		
		else
		{
			dest.writeln(line);
		}
	}
}
