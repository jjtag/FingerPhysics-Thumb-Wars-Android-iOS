package code;

import java.util.ArrayList;
import java.util.List;

public class BcClassDefinition 
{
	private String name;
	private String extendsName;
	
	private List<BcFuncDefinition> functions;
	private List<BcPropertyDefinition> properties;
	
	public BcClassDefinition(String name)
	{
		this.name = name;
		functions = new ArrayList<BcFuncDefinition>();
		properties = new ArrayList<BcPropertyDefinition>();
	}	
	
	public String getName()
	{
		return name;
	}

	public void setExtendsName(String extendsName)
	{
		this.extendsName = extendsName;
	}
	
	public String getExtendsName()
	{
		return extendsName;
	}
	
	public void addFunc(BcFuncDefinition bcFunc)
	{
		functions.add(bcFunc);
	}
	
	public void addProperty(BcPropertyDefinition bcProperty)
	{
		properties.add(bcProperty);
	}
	
	public BcPropertyDefinition findProperty(String name)
	{
		for (BcPropertyDefinition property : properties)
		{
			if (property.getName().equals(name))
			{
				return property;
			}
		}
		
		return null;
	}
}
