package code;

public class BcFuncParam
{
	private String name;
	private BcType type;
	
	public BcFuncParam(String name, BcType type)
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
