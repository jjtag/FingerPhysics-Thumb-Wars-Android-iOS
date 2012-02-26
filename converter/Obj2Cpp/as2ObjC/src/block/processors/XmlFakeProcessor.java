package block.processors;

import static block.RegexHelp.DOT;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.MBSPACE;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import as2ObjC.CodeHelper;

public class XmlFakeProcessor extends LineProcessor 
{
	
	private Pattern pattern = Pattern.compile(IDENTIFIER + MBSPACE + DOT + MBSPACE + "@" + IDENTIFIER);
	
	@Override
	public String process(String line) 
	{
		Matcher m;
		while ((m = pattern.matcher(line)).find())
		{
			String target = CodeHelper.identifier(m.group(1));
			String name = m.group(2);
			line = m.replaceFirst(String.format("[%s getProperty:@\"%s\"]", target, name));
		}
		return line;
	}

}
