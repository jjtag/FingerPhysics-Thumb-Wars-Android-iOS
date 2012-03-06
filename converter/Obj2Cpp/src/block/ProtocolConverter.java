package block;

import java.util.List;

import bc.converter.CodeHelper;
import bc.converter.ListWriteDestination;
import bc.converter.WriteDestination;

import code.BcFuncDefinition;
import code.BcFuncParam;

public class ProtocolConverter extends Converter
{
	public ProtocolConverter(BlockIterator iter, WriteDestination dest)
	{
		super(iter, dest);
	}

	@Override
	protected void process(String line)
	{
		BcFuncDefinition bcFunc;
		if ((bcFunc = BcFunctionCapture.tryCapture(line)) != null)
		{
			ListWriteDestination paramsDest = new ListWriteDestination();
			List<BcFuncParam> funcParams = bcFunc.getParams();
			int index = 0;
			for (BcFuncParam param : funcParams)
			{
				paramsDest.writef("%s %s", param.getType().getName(), param.getName());
				if (++index < funcParams.size())
				{
					paramsDest.write(", ");
				}
			}
			String returnType = bcFunc.getReturnType().getName();
			dest.writef("virtual %s %s(%s) ", returnType, bcFunc.getName(), paramsDest);
			
			String defaultValue = CodeHelper.typeDefault(returnType);
			if (defaultValue != null)
			{
				dest.writelnf("{ return %s; }", defaultValue);
			}
			else
			{
				dest.writeln("{}");
			}
		}
		else if (line.contains("@optional"))
		{
			dest.writeln("// " + line);
		}
		else
		{
			dest.writeln(line);
		}
	}
}
