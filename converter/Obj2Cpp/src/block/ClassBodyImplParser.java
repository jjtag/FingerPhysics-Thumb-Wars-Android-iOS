package block;

import static block.RegexHelp.ANY;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.SPACE;
import static block.RegexHelp.mb;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import bc.converter.CodeHelper;
import bc.converter.ListWriteDestination;
import bc.converter.WriteDestination;

import code.BcClassDefinition;
import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcPropertyDefinition;
import code.PropertyAssignType;

public class ClassBodyImplParser extends Parser
{
	private static Pattern syntesizePattern = Pattern.compile("@synthesize" + SPACE + ANY + ";");
	private static Pattern syntesizeEntryPattern = Pattern.compile(IDENTIFIER + mb(MBSPACE + "=" + MBSPACE + IDENTIFIER));

	private BcClassDefinition bcClass;

	public ClassBodyImplParser(BlockIterator iter, WriteDestination dest, BcClassDefinition bcClass)
	{
		super(iter, dest);
		this.bcClass = bcClass;
	}

	@Override
	protected void process(String line)
	{
		Matcher m;
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
			dest.writelnf("%s %s::%s(%s)", bcFunc.getReturnType().getName(), bcClass.getName(), bcFunc.getName(), paramsDest);
			dest.writeBlockOpen();
			BlockIterator bodyIter = iter.readBlock();

			FunctionBodyParser parser = new FunctionBodyParser(bodyIter, dest, bcClass);
			parser.parse();

			dest.writeBlockClose();
		}
		else if ((m = syntesizePattern.matcher(line)).find())
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
		else
		{
			dest.writeln(line);
		}
	}

	private void writeProperty(BcPropertyDefinition property)
	{
		String propType = CodeHelper.type(property.getType());
		String propBindName = CodeHelper.identifier(property.getBindingName());
		
		dest.writelnf("%s %s::%s()", propType, bcClass.getName(), property.getterName());
		dest.writeBlockOpen();
		dest.writelnf("return %s;", propBindName);
		dest.writeBlockClose();
		
		if (!property.isReadonly())
		{
			dest.writelnf("void %s::set%s(%s __value)", bcClass.getName(), property.setterName(), propType);
			dest.writeBlockOpen();
			
			if (property.getAssignType() == PropertyAssignType.ASSIGN)
			{
				dest.writelnf("%s = __value;", propBindName);
			}
			else
			{
				dest.writelnf("if (%s != __value)", propBindName);
				dest.writeBlockOpen();
				dest.writelnf("%s->release();", propBindName);
				if (property.getAssignType() == PropertyAssignType.RETAIN)
				{
					dest.writelnf("%s = __value->retain();", propBindName);
				}
				else if (property.getAssignType() == PropertyAssignType.COPY)
				{
					dest.writelnf("%s = __value->copy();", propBindName);
				}
				dest.writeBlockClose();
			}
			
			dest.writeBlockClose();
		}		
	}
}
