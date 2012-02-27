package block;

import java.util.ArrayList;
import java.util.List;

import block.processors.ArrayLiteralProcessor;
import block.processors.ArrayProcessor;
import block.processors.DoubleToFloat;
import block.processors.FieldVarProcessor;
import block.processors.FunctionCallProcessor;
import block.processors.LineProcessor;
import block.processors.StringLiteralProcessor;

public class ClassParser 
{
	private FieldVarProcessor varProcessor;
	
	private List<LineProcessor> processors;

	public ClassParser()
	{		
		processors = new ArrayList<LineProcessor>();
		processors.add(new ArrayLiteralProcessor());
		processors.add(new ArrayProcessor());
		processors.add(new FunctionCallProcessor());
		processors.add(new DoubleToFloat());
		processors.add(new StringLiteralProcessor());
		processors.add(varProcessor = new FieldVarProcessor());
	}
	
	public void parse(List<String> lines)
	{
		BlockIterator iterator = new BlockIterator(lines);
		
		int counter = 0;
		while (iterator.hasNext()) 
		{
			String line = iterator.next();
			counter += countParentnessis(line);
			if (counter == 2)
			{
				for (LineProcessor processor : processors) 
				{
					line = processor.process(line);
				}
			}
		}
	}

	private int countParentnessis(String line)
	{
		int counter = 0;
		for (int i = 0; i < line.length(); i++) 
		{
			char chr = line.charAt(i);
			if (chr == '{')
				counter++;
			else if (chr == '}')
				counter--;
		}
		return counter;
	}
	
	
	private String findInitializer(String field)
	{
		List<FieldDeclaration> vars = varProcessor.getVariables();
		for (FieldDeclaration var : vars) 
		{
			if (var.getName().equals(field))
				return var.getInitializer();
		}
		return null;
	}
}
