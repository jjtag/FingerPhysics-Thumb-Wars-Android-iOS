package block.processors.group;

import java.util.ArrayList;
import java.util.List;

import block.processors.LineProcessor;
import block.processors.ReplaceTokensProcessor;
import block.processors.StringLiteralProcessor;

public class ProcessorsGroup
{
	private List<LineProcessor> processors;
	
	public ProcessorsGroup()
	{
		processors = new ArrayList<LineProcessor>();
		processors.add(new StringLiteralProcessor());
		processors.add(new ReplaceTokensProcessor());
	}
	
	protected void addProcessor(LineProcessor processor)
	{
		processors.add(processor);
	}
	
	public String process(String line)
	{
		for (LineProcessor processor : processors)
		{
			if (line.trim().startsWith("//"))
			{
				continue;
			}
			line = processor.process(line);
		}
		return line;
	}
}
