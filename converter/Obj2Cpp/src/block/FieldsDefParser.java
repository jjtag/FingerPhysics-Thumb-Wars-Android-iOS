package block;

import static block.RegexHelp.ANY;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.STAR;
import static block.RegexHelp.group;
import static block.RegexHelp.mb;
import static block.RegexHelp.or;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import bc.converter.WriteDestination;

import code.BcClassDefinition;
import code.BcFieldDefinition;
import code.BcType;

public class FieldsDefParser extends Parser
{
	private static Pattern fieldPattern = Pattern.compile(IDENTIFIER + MBSPACE + ANY + ";");
	private static Pattern fieldProtocolPattern = Pattern.compile(group("id" + MBSPACE + "<" + MBSPACE + IDENTIFIER + MBSPACE + ">") + MBSPACE + ANY + ";");
	private static Pattern fieldEntry = Pattern.compile(mb(STAR) + MBSPACE + IDENTIFIER);
	
	private static Pattern visiblityPattern = Pattern.compile("@" + group(or("public", "private", "protected")));
	
	private BcClassDefinition bcClass;

	public FieldsDefParser(BlockIterator iter, WriteDestination dest, BcClassDefinition bcClass)
	{
		super(iter, dest);
		this.bcClass = bcClass;
	}

	@Override
	protected void process(String line)
	{
		Matcher m;
		if ((m = fieldProtocolPattern.matcher(line)).find())
		{
			String typeName = m.group(2) + "*";
			String entriesStr = m.group(1);
			
			addFields(typeName, entriesStr);
			
			dest.writeln(line.replace(m.group(1), typeName));
		}
		else if ((m = fieldPattern.matcher(line)).find())
		{
			String typeName = m.group(1);
			String entriesStr = m.group(2);
			
			addFields(typeName, entriesStr);
			
			dest.writeln(line);
		}
		else if ((m = visiblityPattern.matcher(line)).find())
		{
			String modifier = m.group(1);
			dest.decTab();
			dest.writeln(m.replaceFirst(modifier + ":"));
			dest.incTab();
		}
		else
		{		
			dest.writeln(line);
		}
	}
	
	private void addFields(String typeName, String entriesStr)
	{
		Matcher matcher = fieldEntry.matcher(entriesStr);
		while (matcher.find())
		{
			boolean isReference = matcher.group(1) != null;
			String name = matcher.group(2);

			String type = typeName + (isReference ? "*" : "");
			
			BcFieldDefinition bcField = new BcFieldDefinition(name, new BcType(type));
			bcClass.addField(bcField);
		}
	}

}
