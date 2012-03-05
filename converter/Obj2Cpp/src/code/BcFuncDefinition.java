package code;

import java.util.ArrayList;
import java.util.List;

public class BcFuncDefinition
{
	private String name;
	private BcType returnType;
	
	private boolean isStatic;
	private boolean isInitializer;
	
	private List<BcFuncParam> params;
	
	public BcFuncDefinition(String name, BcType returnType)
	{
		this.name = name;
		this.returnType = returnType;
		
		params = new ArrayList<BcFuncParam>();
	}
	
	public String getName()
	{
		return name;
	}
	
	public BcType getReturnType()
	{
		return returnType;
	}
	
	public boolean isStatic()
	{
		return isStatic;
	}
	
	public void setStatic(boolean flag)
	{
		isStatic = flag;
	}
	
	public void setInitializer(boolean isInitializer)
	{
		this.isInitializer = isInitializer;
	}
	
	public boolean isInitializer()
	{
		return isInitializer;
	}
	
	public void addParam(BcFuncParam param)
	{
		params.add(param);
	}

	public List<BcFuncParam> getParams()
	{
		return params;		
	}
}
