package block.processors;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.LBRKT;
import static block.RegexHelp.RBRKT;
import static block.RegexHelp.DOT;
import static block.RegexHelp.ANY;

import static block.RegexHelp.group;

public class ArrayLiteralProcessor extends LineProcessor
{
	private Pattern pattern = Pattern.compile(group("Vector" + DOT + "<" + MBSPACE + IDENTIFIER + MBSPACE + ">" + MBSPACE + LPAR + MBSPACE + LBRKT + ANY + RBRKT + MBSPACE + RPAR));

	@Override
	public String process(String line)
	{
		Matcher m;
		while ((m = pattern.matcher(line)).find())
		{
			line = m.replaceFirst("[[NSArray alloc] initWithObjects:" + m.group(3) + ", nil]");
		}
		
		return line;
	}

}
