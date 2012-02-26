package block.processors;

import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.SPACE;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import as2ObjC.CodeHelper;

public class VarLineProcessor extends LineProcessor
{
	private Pattern pattern = Pattern.compile("(var|const)" + SPACE + IDENTIFIER + MBSPACE + ":" + MBSPACE + IDENTIFIER);
	
	private List<String> types = new ArrayList<String>();
	
	@Override
	public String process(String line)
	{
		Matcher m;
		if ((m = pattern.matcher(line)).find())
		{
			String type = m.group(3);
			String name = m.group(2);
			
			assert type != null : line;
			assert name != null : line;
			
			if (CodeHelper.canBeType(type))
			{
				types.add(type);
			}
			
			line = m.replaceFirst(CodeHelper.type(type) + " " + name);
		}
		
		return line;
	}

	public List<String> getTypes() 
	{
		return types;
	}
}
