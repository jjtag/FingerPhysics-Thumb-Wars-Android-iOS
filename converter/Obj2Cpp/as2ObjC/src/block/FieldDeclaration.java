package block;

public class FieldDeclaration 
{
	private String type;
	private String name;
	private String visiblity = "public";
	
	private boolean isStatic;
	
	private String initializer;

	public FieldDeclaration(String type, String name) 
	{
		this.type = type;
		this.name = name;
	}

	public void setStatic(boolean isStatic) 
	{
		this.isStatic = isStatic;
	}
	
	public void setVisiblity(String visiblity) 
	{
		this.visiblity = visiblity;
	}
	
	public boolean isStatic() 
	{
		return isStatic;
	}
	
	public void setInitializer(String initializer) 
	{
		this.initializer = initializer;
	}
	
	public String getType() 
	{
		return type;
	}

	public String getName() 
	{
		return name;
	}

	public String getVisiblity() 
	{
		return visiblity;
	}
	
	public String getInitializer() 
	{
		return initializer;
	}
}
