package block;

import static block.RegexHelp.ANY;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.SPACE;
import static block.RegexHelp.TIDENTIFIER;
import static block.RegexHelp.mb;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import bc.converter.WriteDestination;

import code.BcClassDefinition;

public class HeaderParser extends Parser
{
	private static Pattern interfacePattern = Pattern.compile("@interface" + SPACE + TIDENTIFIER + mb(MBSPACE + ":" + MBSPACE + TIDENTIFIER + MBSPACE + mb("<" + ANY + ">")));
	private static Pattern typePattern = Pattern.compile(TIDENTIFIER);
	
	private static Pattern protocolPattern = Pattern.compile("@protocol" + SPACE + TIDENTIFIER);

	private BcClassDefinition lastBcClass;
	private Map<String, BcClassDefinition> bcClasses;

	public HeaderParser(BlockIterator iter, WriteDestination dest, Map<String, BcClassDefinition> bcClasses)
	{
		super(iter, dest);
		this.bcClasses = bcClasses;
		preprocessingEnabled = false;
	}

	public void process(String line)
	{
		Matcher m;
		if ((m = interfacePattern.matcher(line)).find())
		{
			assert lastBcClass == null : lastBcClass.getName();

			String className = m.group(1);
			String extendsName = m.group(3) == null ? "NSObject" : m.group(3);
			String interfaces = m.group(5);

			assert !bcClasses.containsKey(className);
			lastBcClass = new BcClassDefinition(className);
			lastBcClass.setExtendsName(extendsName);
			bcClasses.put(className, lastBcClass);

			dest.write("class " + className + " : public " + extendsName);
			if (interfaces != null)
			{
				m = typePattern.matcher(interfaces);
				while (m.find())
				{
					dest.write(", public " + m.group(1));
				}
			}
			dest.writeln();
			dest.writeBlockOpen();

			dest.decTab();
			dest.writeln("private:");
			dest.incTab();
			
			String bodyLine;
			bodyLine = iter.next();
			if (bodyLine.equals("{"))
			{
				BlockIterator fieldsIter = new BlockIterator();
				while (!(bodyLine = iter.next()).equals("}"))
				{
					fieldsIter.add(bodyLine);
				}
				new FieldsDefParser(fieldsIter, dest, lastBcClass).parse();
			}
			else
			{
				iter.pushBack();
			}
			
			dest.writeln();
			dest.decTab();
			dest.writeln("public:");
			dest.incTab();
			
			writeConstructor();
			
			BlockIterator classIter = new BlockIterator();			
			while (!(bodyLine = iter.next()).equals("@end"))
			{
				classIter.add(bodyLine);
			}
			preprocessingEnabled = false;
			
			new ClassBodyHeaderParser(classIter, dest, lastBcClass).parse();
			
			dest.writeBlockClose(true);
			
			lastBcClass = null;
		}
		else if ((m = protocolPattern.matcher(line)).find())
		{
			String name = m.group(1);
			dest.writelnf("class %s", name);
			dest.writeBlockOpen();
			
			dest.decTab();
			dest.writeln("public:");
			dest.incTab();
			
			BlockIterator bodyIter = new BlockIterator();
			String bodyLine;
			while (!(bodyLine = iter.next()).equals("@end"))
			{
				bodyIter.add(bodyLine);
			}
			preprocessingEnabled = false;
			
			new ProtocolParser(bodyIter, dest).parse();
			
			dest.writeBlockClose(true);			
		}
		else
		{
			dest.writeln(line);
			
			if (!preprocessingEnabled)
			{
				String nextLine = peek();
				if (nextLine != null && (nextLine.contains("@interface") || nextLine.contains("@protocol")))
				{
					preprocessingEnabled = true;
				}
			}
		}
	}

	private void writeConstructor()
	{
		dest.writelnf("%s();", lastBcClass.getName());
		dest.writeln();
	}
}
