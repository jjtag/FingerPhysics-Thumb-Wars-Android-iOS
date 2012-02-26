package block.processors;

import static block.RegexHelp.ANY;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.SPACE;
import static block.RegexHelp.mb;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import block.FieldDeclaration;

public class FieldVarProcessor extends LineProcessor 
{
	private Pattern pattern = Pattern.compile(mb("private|protected|public") + MBSPACE + mb("static") + MBSPACE + mb("var") + SPACE + IDENTIFIER + MBSPACE + ":" + MBSPACE + IDENTIFIER + MBSPACE + mb("=") + MBSPACE + ANY + ";");
	
	private List<FieldDeclaration> variables;
	
	public FieldVarProcessor() 
	{
		variables = new ArrayList<FieldDeclaration>();
	}

	@Override
	public String process(String line) 
	{
		Matcher m;
		if ((m = pattern.matcher(line)).find())
		{
			String modifier = m.group(1);
			boolean isStatic = m.group(2) != null;
			String identifier = m.group(4);
			String type = m.group(5);
			String initializer = m.group(7);
			
			FieldDeclaration var = new FieldDeclaration(type, identifier);
			if (modifier != null)
				var.setVisiblity(modifier);
			var.setStatic(isStatic);
			initializer = initializer != null && initializer.length() > 0 ? initializer : null;
			var.setInitializer(initializer);			
			
			variables.add(var);
		}
		return line;
	}

	public List<FieldDeclaration> getVariables() 
	{
		return variables;
	}

}
