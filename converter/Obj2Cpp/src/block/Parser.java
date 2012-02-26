package block;

import java.util.List;

import as2ObjC.ListWriteDestination;

public abstract class Parser
{
	protected BlockIterator iter;
	protected ListWriteDestination dest;

	public Parser(BlockIterator iter)
	{
		this.iter = iter;
		dest = new ListWriteDestination();
	}

	public abstract void parse();
	
	public List<String> getCodeLines()
	{
		return dest.getLines();
	}
}