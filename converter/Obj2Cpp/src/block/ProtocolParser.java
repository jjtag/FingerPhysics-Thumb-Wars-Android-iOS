package block;

import java.util.List;

import bc.converter.ListWriteDestination;
import bc.converter.WriteDestination;

import code.BcFuncDefinition;
import code.BcFuncParam;

public class ProtocolParser extends Parser
{
	public ProtocolParser(BlockIterator iter, WriteDestination dest)
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
			dest.writelnf("virtual %s %s(%s) = 0;", bcFunc.getReturnType().getName(), bcFunc.getName(), paramsDest);
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
