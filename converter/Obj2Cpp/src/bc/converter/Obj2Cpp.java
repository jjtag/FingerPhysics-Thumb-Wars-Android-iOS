package bc.converter;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import bc.utils.file.FileUtils;
import block.BlockIterator;
import block.FunctionBodyConverter;
import block.HeaderConverter;
import block.ImplConverter;
import block.Converter;
import block.processors.group.ProcessorsGroup;
import code.BcClassDefinition;
import code.BcPropertyDefinition;

public class Obj2Cpp 
{
	private static Map<String, BcClassDefinition> bcClasses;
	
	public static void main(String[] args) 
	{
		File outputDir = new File(args[0]);
		bcClasses = new HashMap<String, BcClassDefinition>();
		
		try
		{
			for (int i = 1; i < args.length; ++i)
			{
				File asSourceFile = new File(args[i]);
				process(asSourceFile, outputDir, ".h"); // collect headers first
			}

			// das hack
			Collection<BcClassDefinition> classes = bcClasses.values();
			for (BcClassDefinition bcClass : classes)
			{
				List<BcPropertyDefinition> properties = bcClass.getProperties();
				for (BcPropertyDefinition bcProperty : properties)
				{
					FunctionBodyConverter.registerProperty(bcProperty);
				}
			}
			
			for (int i = 1; i < args.length; ++i)
			{
				File asSourceFile = new File(args[i]);
				process(asSourceFile, outputDir, ".m", ".mm"); // collect the rest of sources
			}
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
    }
	
	private static void process(File file, File outputDir, String...extensions) throws IOException
	{
		if (file.isDirectory())
		{
			File[] files = FileUtils.listFiles(file, extensions);
			
			for (File child : files) 
			{				
				process(child, new File(outputDir, file.getName()), extensions);
			}
		}
		else
		{
			convert(file, outputDir);
		}
	}
	
	private static void convert(File source, File outputDir) throws IOException 
	{
		System.out.println("Converting: " + source);
		
		String sourceName = source.getName();		
		
		List<String> lines = FileUtils.readFile(source);
		BlockIterator iter = new BlockIterator(lines);
		
		ListWriteDestination dest = new ListWriteDestination();
		
		Converter converter;
		if (sourceName.endsWith(".h"))
		{
			converter = new HeaderConverter(iter, dest, bcClasses);
		}
		else
		{
			converter = new ImplConverter(iter, dest, bcClasses);
		}
		converter.convert();
		
		List<String> convertedLines = dest.getLines();
		List<String> processedLines = new ArrayList<String>(convertedLines.size());
		
		ProcessorsGroup processor = new ProcessorsGroup();
		for (String line : convertedLines)
		{
			processedLines.add(processor.process(line));
		}
		
		outputDir.mkdirs();
		File outFile = new File(outputDir, source.getName());
		writeCode(outFile, processedLines);		
	}

	private static void writeCode(File outFile, List<String> lines) throws IOException
	{
		FileWriteDestination dest = new FileWriteDestination(outFile);
		
		boolean needsDefGuard = outFile.getName().endsWith(".h");
		String defguardName = String.format("___%s_h_", FileUtils.fileNameNoExt(outFile));
		
		if (needsDefGuard)
		{
			dest.writelnf("#ifndef %s", defguardName);
			dest.writelnf("#define %s", defguardName);
			dest.writeln();
		}
		
		for (String line : lines)
		{
			dest.writeln(line);
		}
		
		if (needsDefGuard)
		{
			dest.writeln();
			dest.writelnf("#endif // %s", defguardName);
		}
		
		dest.close();
	}
}