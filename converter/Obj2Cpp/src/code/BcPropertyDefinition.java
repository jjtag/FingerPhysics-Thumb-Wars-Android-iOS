package code;

public class BcPropertyDefinition
{
	enum AssignType
	{
		ASSIGN,
		COPY,
		RETAIN
	}
	
	private String name;
	private String type;
	
	private boolean readonly;
	private AssignType assignType;

	public BcPropertyDefinition(String name, String type)
	{
		this.name = name;
		this.type = type;
		
		assignType = AssignType.ASSIGN;
	}
	
	public void setModifier(String modifier)
	{
		if (modifier.equals("readonly"))
		{
			readonly = true;
		}
		else if (modifier.equals("retain"))
		{
			assignType = AssignType.RETAIN;
		}
		else if (modifier.equals("copy"))
		{
			assignType = AssignType.COPY;
		}
		else if (modifier.equals("assign"))
		{
			assignType = AssignType.ASSIGN;
		}
	}
	
	public boolean isReadonly()
	{
		return readonly;
	}
	
	public AssignType getAssignType()
	{
		return assignType;
	}
	
	public String getName()
	{
		return name;
	}

	public String getType()
	{
		return type;
	}
}
