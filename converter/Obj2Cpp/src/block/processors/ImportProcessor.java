package block.processors;

public class ImportProcessor extends LineProcessor
{
	@Override
	public String process(String line)
	{
		if (line.startsWith("#import"))
		{
			return line.replace("#import", "#include");
		}
		
		return line;
	}
}
