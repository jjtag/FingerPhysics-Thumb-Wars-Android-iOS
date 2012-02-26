package block.processors;

import static block.RegexHelp.DOT;
import static block.RegexHelp.group;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DoubleToFloat extends LineProcessor
{
	private static Pattern pattern = Pattern.compile(group("[\\-+\\d]+" + DOT + "[\\d]+") + group("[^fF\\d]"));
	
	@Override
	public String process(String line)
	{
		String temp = line;
		
		Matcher matcher;
		while ((matcher = pattern.matcher(temp)).find())
		{
			String number = matcher.group(1);
			String token = matcher.group(2);
			temp = matcher.replaceFirst(number + "f" + token);
		}
		return temp;
	}
}
