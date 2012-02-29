package code;

public class BcPropertyDefinition
{
	
	private String name;
	private BcType type;
	
	private boolean readonly;
	private PropertyAssignType assignType;

	public BcPropertyDefinition(String name, BcType type)
	{
		this.name = name;
		this.type = type;
		
		assignType = PropertyAssignType.ASSIGN;
	}
	
	public void setModifier(String modifier)
	{
		if (modifier.equals("readonly"))
		{
			readonly = true;
		}
		else if (modifier.equals("retain"))
		{
			assignType = PropertyAssignType.RETAIN;
		}
		else if (modifier.equals("copy"))
		{
			assignType = PropertyAssignType.COPY;
		}
		else if (modifier.equals("assign"))
		{
			assignType = PropertyAssignType.ASSIGN;
		}
	}
	
	public boolean isReadonly()
	{
		return readonly;
	}
	
	public PropertyAssignType getAssignType()
	{
		return assignType;
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
