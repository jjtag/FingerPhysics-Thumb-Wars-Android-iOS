package code;

import java.util.ArrayList;
import java.util.List;

public class BcClassDefinition 
{
	private String name;
	private String extendsName;
	
	private List<BcFuncDefinition> functions;
	private List<BcPropertyDefinition> properties;
	private List<BcFieldDefinition> fields;
	
	public BcClassDefinition(String name)
	{
		this.name = name;
		functions = new ArrayList<BcFuncDefinition>();
		properties = new ArrayList<BcPropertyDefinition>();
		fields = new ArrayList<BcFieldDefinition>();
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
	
	public void addField(BcFieldDefinition bcField)
	{
		fields.add(bcField);
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
	
	public List<BcPropertyDefinition> getProperties()
	{
		return properties;
	}
	
	public List<BcFieldDefinition> getFields()
	{
		return fields;
	}
}
