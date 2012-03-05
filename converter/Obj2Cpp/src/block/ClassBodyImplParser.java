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
			BlockIterator bodyIter = iter.readBlock();

			dest.writeBlockOpen();
			
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
		
		dest.writelnf("%s %s::%s() { return %s; }", propType, bcClass.getName(), property.getterName(), propBindName);
		
		if (!property.isReadonly())
		{
			dest.writef("void %s::%s(%s __value) { ", bcClass.getName(), property.setterName(), propType);
			
			if (property.getAssignType() == PropertyAssignType.ASSIGN)
			{
				dest.writef("%s = __value; ", propBindName);
			}
			else
			{
				dest.writef("if (%s != __value) { ", propBindName);				
				dest.writef("%s->release(); ", propBindName);
				if (property.getAssignType() == PropertyAssignType.RETAIN)
				{
					dest.writef("%s = __value->retain(); ", propBindName);
				}
				else if (property.getAssignType() == PropertyAssignType.COPY)
				{
					dest.writef("%s = __value->copy(); ", propBindName);
				}
				dest.write("}");
			}
			
			dest.writeln("}");
		}		
	}
}
