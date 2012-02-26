package code.processor;

import block.processors.group.ProcessorsGroup;
import code.BcClassDefinition;

public class TopLevelProcessorsGroup extends ProcessorsGroup
{
	private BcClassDefinition lastClass;
	
	public TopLevelProcessorsGroup()
	{
		addProcessor(new HeaderProcessor());
	}
}
