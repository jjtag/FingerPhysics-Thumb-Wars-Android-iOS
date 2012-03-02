package code;

public class BcFieldDefinition
{
	private String name;
	private BcType type;

	public BcFieldDefinition(String name, BcType type)
	{
		this.name = name;
		this.type = type;
	}

	public String getName()
	{
		return name;
	}
	
	public BcType getType()
	{
		return type;
	}
}
