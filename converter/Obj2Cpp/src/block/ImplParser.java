package block;

import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.ANY;
import static block.RegexHelp.PLUS;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.SPACE;
import static block.RegexHelp.TIDENTIFIER;
import static block.RegexHelp.group;
import static block.RegexHelp.mb;
import static block.RegexHelp.or;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import as2ObjC.ListWriteDestination;
import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcType;

public class ImplParser extends Parser
{
	private static Pattern implPattern = Pattern.compile("@implementation" + SPACE + TIDENTIFIER);
	private static Pattern syntesizePattern = Pattern.compile("@synthesize" + SPACE + ANY + ";");
	
	private static Pattern methodDef = Pattern.compile(group(or(PLUS, "-")) + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + MBSPACE + mb(":") + ANY);
	private static Pattern paramDef = Pattern.compile(LPAR + ANY + RPAR + MBSPACE + IDENTIFIER);
	
	private String implClass;
	
	public ImplParser(BlockIterator iter)
	{
		super(iter);
	}

	@Override
	public void parse()
	{
		while (iter.hasNext())
		{
			process(iter.next());
		}
	}

	private void process(String line)
	{
		Matcher m;

		if ((m = implPattern.matcher(line)).find())
		{
			System.out.println(line);
			
			assert implClass == null : implClass;
			
			implClass = m.group(1);
			
			String bodyLine;
			while (!(bodyLine = iter.next()).equals("@end"))
			{
				processClassBody(bodyLine);
			}
			implClass = null;
		}
		else
		{
			dest.writeln(line);
		}
	}

	private void processClassBody(String line)
	{
		Matcher m;
		if ((m = syntesizePattern.matcher(line)).find())
		{
			dest.writeln(line);
		}
		else if ((m = methodDef.matcher(line)).find())
		{
			String returnType = m.group(2);
			String methodName = m.group(3);
			boolean hasParams = m.group(4) != null;

			BcFuncDefinition bcFunc = new BcFuncDefinition(methodName, new BcType(returnType));

			ListWriteDestination paramsDest = new ListWriteDestination();
			if (hasParams)
			{
				String params = m.group(5);
				m = paramDef.matcher(params);
				while (m.find())
				{
					String paramType = m.group(1);
					String paramName = m.group(2);

					bcFunc.addParam(new BcFuncParam(paramName, new BcType(paramType)));
				}

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
			}
			dest.writelnf("%s %s::%s(%s)", returnType, implClass, methodName, paramsDest);
			dest.writeBlockOpen();
			BlockIterator bodyIter = iter.readBlock();
			while (bodyIter.hasNext())
			{
				processFuncBody(bodyIter.next());
			}
			dest.writeBlockClose();
		}
		else
		{
			dest.writeln(line);
		}
	}

	private void processFuncBody(String line)
	{
		if (line.equals("{"))
		{
			dest.writeln(line);
			dest.incTab();
		}
		else if (line.equals("}"))
		{
			dest.decTab();
			dest.writeln(line);
		}
		else
		{
			dest.writeln(line);
		}
	}
}
