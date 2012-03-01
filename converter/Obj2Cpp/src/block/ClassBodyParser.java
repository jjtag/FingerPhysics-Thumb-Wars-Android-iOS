package block;

import static block.RegexHelp.ALL;
import static block.RegexHelp.ANY;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.PLUS;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.SPACE;
import static block.RegexHelp.group;
import static block.RegexHelp.mb;
import static block.RegexHelp.or;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import as2ObjC.CodeHelper;
import as2ObjC.ListWriteDestination;
import as2ObjC.WriteDestination;
import code.PropertyAssignType;
import code.BcClassDefinition;
import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcPropertyDefinition;
import code.BcType;

public class ClassBodyParser extends Parser
{
	private static Pattern syntesizePattern = Pattern.compile("@synthesize" + SPACE + ANY + ";");
	private static Pattern syntesizeEntryPattern = Pattern.compile(IDENTIFIER + mb(MBSPACE + "=" + MBSPACE + IDENTIFIER));

	private static Pattern methodDef = Pattern.compile(group(or(PLUS, "-")) + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + MBSPACE + mb(":") + ALL);
	private static Pattern paramDef = Pattern.compile(LPAR + ANY + RPAR + MBSPACE + IDENTIFIER);

	private BcClassDefinition bcClass;

	public ClassBodyParser(BlockIterator iter, WriteDestination dest, BcClassDefinition bcClass)
	{
		super(iter, dest);
		this.bcClass = bcClass;
	}

	@Override
	protected void process(String line)
	{
		Matcher m;
		if ((m = syntesizePattern.matcher(line)).find())
		{
			String propertiesString = m.group(1);
			Matcher matcher = syntesizeEntryPattern.matcher(propertiesString);
			while (matcher.find())
			{
				String name = matcher.group(1);
				String bindingName = matcher.group(3);
				
				BcPropertyDefinition property = bcClass.findProperty(name);
				assert property != null : name;
				
				if (bindingName != null)
				{
					property.setBindingName(bindingName);
				}
				
				writeProperty(property);
			}
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
			dest.writelnf("%s %s::%s(%s)", returnType, bcClass.getName(), methodName, paramsDest);
			dest.writeBlockOpen();
			BlockIterator bodyIter = iter.readBlock();

			FunctionBodyParser parser = new FunctionBodyParser(bodyIter, dest);
			parser.parse();

			dest.writeBlockClose();
		}
		else
		{
			dest.writeln(line);
		}
	}

	private void writeProperty(BcPropertyDefinition property)
	{
		String propType = CodeHelper.type(property.getType());
		String propName = CodeHelper.identifier(property.getName());
		String propBindName = CodeHelper.identifier(property.getBindingName());
		
		dest.writelnf("%s %s::%s()", propType, bcClass.getName(), propName);
		dest.writeBlockOpen();
		dest.writelnf("return %s;", propBindName);
		dest.writeBlockClose();
		
		if (!property.isReadonly())
		{
			dest.writelnf("void %s::set%s(%s __value)", bcClass.getName(), Character.toUpperCase(propName.charAt(0)) + propName.substring(1), propType);
			dest.writeBlockOpen();
			
			if (property.getAssignType() == PropertyAssignType.ASSIGN)
			{
				dest.writelnf("%s = __value;", propBindName);
			}
			else
			{
				dest.writelnf("if (%s != __value)", propBindName);
				dest.writeBlockOpen();
				dest.writelnf("[%s release];", propBindName);
				if (property.getAssignType() == PropertyAssignType.RETAIN)
				{
					dest.writelnf("%s = [__value retain];", propBindName);
				}
				else if (property.getAssignType() == PropertyAssignType.COPY)
				{
					dest.writelnf("%s = [__value copy];", propBindName);
				}
				dest.writeBlockClose();
			}
			
			dest.writeBlockClose();
		}		
	}
}
