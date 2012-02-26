package block.processors;

import static block.RegexHelp.DOT;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.TIDENTIFIER;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ArrayProcessor extends LineProcessor 
{
	private Pattern pattern = Pattern.compile("Vector" + MBSPACE + DOT + MBSPACE + "<" + MBSPACE + TIDENTIFIER + MBSPACE + ">");
	
	@Override
	public String process(String line) 
	{
		Matcher m;
		while ((m = pattern.matcher(line)).find())
		{
			line = m.replaceFirst("NSArray");
		}
		
		return line;
	}

}
