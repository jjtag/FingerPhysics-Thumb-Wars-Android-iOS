package block;

import java.util.ArrayList;
import java.util.List;

import code.processor.TopLevelProcessorsGroup;

import block.processors.group.ProcessorsGroup;

public class BlockParser
{
	private ProcessorsGroup processors;	
	
	public BlockParser()
	{		
		processors = new TopLevelProcessorsGroup();
	}
	
	public List<String> parse(String body)
	{
		BlockIterator iter = new BlockIterator(body);
		
		List<String> lines = new ArrayList<String>();
		while (iter.hasNext())
		{
			String line = iter.next();
			lines.add(process(line));
		}
		
		return lines;
	}

	private String process(String line)
	{
		return processors.process(line);
	}	
}
