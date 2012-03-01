package as2ObjC;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import code.BcClassDefinition;

import bc.utils.file.FileUtils;
import block.BlockIterator;
import block.BlockParser;
import block.HeaderParser;
import block.ImplParser;
import block.Parser;

public class As2ObjC 
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
		
		Parser parser;
		if (sourceName.endsWith(".h"))
		{
			HeaderParser headerParse = new HeaderParser(iter, dest, bcClasses);
			parser = headerParse;
		}
		else
		{
			parser = new ImplParser(iter, dest, bcClasses);
		}
		
		parser.parse();
		
		outputDir.mkdirs();
		
		File outFile = new File(outputDir, source.getName());
		writeCode(outFile, dest.getLines());		
	}

	private static void writeCode(File outFile, List<String> lines) throws IOException
	{
		FileWriteDestination dest = new FileWriteDestination(outFile);
		
		for (String line : lines)
		{
			dest.writeln(line);
		}
		
		dest.close();
	}
}