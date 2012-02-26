package code;

import java.util.ArrayList;
import java.util.List;

public class BcFuncDefinition
{
	private String name;
	private BcType returnType;
	
	private boolean isStatic;
	
	private List<BcFuncParam> params;
	
	public BcFuncDefinition(String name, BcType returnType)
	{
		this.name = name;
		this.returnType = returnType;
		
		params = new ArrayList<BcFuncParam>();
	}
	
	public boolean isStatic()
	{
		return isStatic;
	}
	
	public void setStatic(boolean flag)
	{
		isStatic = flag;
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
