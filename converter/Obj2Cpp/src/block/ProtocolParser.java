package block;

import static block.RegexHelp.ANY;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.PLUS;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.group;
import static block.RegexHelp.mb;
import static block.RegexHelp.or;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcType;
import as2ObjC.ListWriteDestination;
import as2ObjC.WriteDestination;

public class ProtocolParser extends Parser
{
	private static Pattern methodDef = Pattern.compile("-" + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + MBSPACE + mb(":") + ANY + ";");
	private static Pattern paramDef = Pattern.compile(LPAR + ANY + RPAR + MBSPACE + IDENTIFIER);
	
	public ProtocolParser(BlockIterator iter, WriteDestination dest)
	{
		super(iter, dest);
	}

	@Override
	protected void process(String line)
	{
		Matcher m;
		if ((m = methodDef.matcher(line)).find())
		{
			String returnType = m.group(1);
			String methodName = m.group(2);
			boolean hasParams = m.group(4) != null;

			ListWriteDestination paramsDest = new ListWriteDestination();
			if (hasParams)
			{
				String params = m.group(4);
				m = paramDef.matcher(params);
				
				List<BcFuncParam> funcParams = new ArrayList<BcFuncParam>();
				while (m.find())
				{
					String paramType = m.group(1);
					String paramName = m.group(2);

					funcParams.add(new BcFuncParam(paramName, new BcType(paramType)));
				}

				int index = 0;
				for (BcFuncParam param : funcParams)
				{
					paramsDest.writef("%s %s", param.getType().getName(), param.getName());
					if (++index < funcParams.size())
					{
						paramsDest.write(", ");
					}
				}
			}
			dest.writelnf("virtual %s %s(%s) = 0;", returnType, methodName, paramsDest);
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
