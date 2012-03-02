package block;

import static block.RegexHelp.ANY;
import static block.RegexHelp.IDENTIFIER;
import static block.RegexHelp.LPAR;
import static block.RegexHelp.MBSPACE;
import static block.RegexHelp.RPAR;
import static block.RegexHelp.STAR;
import static block.RegexHelp.group;
import static block.RegexHelp.mb;
import static block.RegexHelp.or;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import code.BcClassDefinition;
import code.BcFuncDefinition;
import code.BcFuncParam;
import code.BcPropertyDefinition;
import code.BcType;
import as2ObjC.CodeHelper;
import as2ObjC.ListWriteDestination;
import as2ObjC.WriteDestination;

public class ClassBodyHeaderParser extends Parser
{
	private static Pattern propertyDef = Pattern.compile("@property" + MBSPACE + LPAR + ANY + RPAR + MBSPACE + IDENTIFIER + ANY + ";");
	private static Pattern propertyEntry = Pattern.compile(mb(STAR) + MBSPACE + IDENTIFIER);
	private static Pattern protocolPropertyDef = Pattern.compile("@property" + MBSPACE + LPAR + ANY + RPAR + MBSPACE + "id" + MBSPACE + "<" + MBSPACE + IDENTIFIER + MBSPACE + mb(STAR) + MBSPACE + ">"+ MBSPACE + ANY + ";");
	private static Pattern modifierDef = Pattern.compile(group(or("assign", "retain", "copy", "readonly", "readwrite", "nonatomic", "atomic")));
	
	private BcClassDefinition bcClass;

	public ClassBodyHeaderParser(BlockIterator iter, WriteDestination dest, BcClassDefinition bcClass)
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
			bcClass.addFunc(bcFunc);

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
			dest.writelnf("%s %s %s(%s);", bcFunc.isStatic() ? "static" : "virtual", bcFunc.getReturnType().getName(), bcFunc.getName(), paramsDest);
		}
		else if ((m = protocolPropertyDef.matcher(line)).find())
		{
			String modifiersString = m.group(1);
			String typeName = m.group(2) + (m.group(3) != null ? "*" : "");			
			String entriesString = m.group(4).trim();
			
			writeProperties(typeName, entriesString, modifiersString);
		}
		else if ((m = propertyDef.matcher(line)).find())
		{
			String modifiersString = m.group(1);
			String typeName = m.group(2);
			
			String entriesString = m.group(3).trim();
			
			writeProperties(typeName, entriesString, modifiersString);
		}
		else
		{
			dest.writeln(line);
		}
	}
	
	private void writeProperties(String typeName, String entriesStr, String modifiersStr)
	{
		Matcher matcher = modifierDef.matcher(modifiersStr);
		List<String> modifiers = new ArrayList<String>();
		while (matcher.find())
		{
			modifiers.add(matcher.group(1));
		}
		
		matcher = propertyEntry.matcher(entriesStr);
		while (matcher.find())
		{
			boolean isReference = matcher.group(1) != null;
			String name = matcher.group(2);

			String type = typeName + (isReference ? "*" : "");
			
			BcPropertyDefinition bcProperty = new BcPropertyDefinition(name, new BcType(type));
			bcClass.addProperty(bcProperty);
			
			for (String modifier : modifiers)
			{
				bcProperty.setModifier(modifier);
			}
			
			String propType = CodeHelper.type(bcProperty.getType());
			String propName = CodeHelper.identifier(name);
			
			dest.writelnf("%s %s();", propType, propName);
			if (!bcProperty.isReadonly())
			{
				dest.writelnf("void set%s(%s __value);", Character.toUpperCase(propName.charAt(0)) + propName.substring(1), propType);
			}				
		}
	}

}
