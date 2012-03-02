package block;

import static block.RegexHelp.SPACE;
import static block.RegexHelp.TIDENTIFIER;

import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import bc.converter.WriteDestination;

import code.BcClassDefinition;
import code.BcFieldDefinition;

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

			writeConstructor(bcClass);
			
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

	private void writeConstructor(BcClassDefinition bcClass)
	{
		String className = bcClass.getName();
		dest.writef("%s::%s()", className, className);
		
		List<BcFieldDefinition> fields = bcClass.getFields();
		dest.writeln(fields.isEmpty() ? "" : " : ");
		
		int index = 0;
		for (BcFieldDefinition field : fields)
		{
			dest.writef("  %s(0)", field.getName());
			dest.writeln(++index < fields.size() ? "," : "");
		}
		
		dest.writeBlockOpen();
		dest.writeBlockClose();
	}
}
