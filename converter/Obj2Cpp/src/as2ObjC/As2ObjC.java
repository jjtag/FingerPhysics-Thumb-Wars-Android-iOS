package as2ObjC;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import bc.utils.file.FileUtils;
import block.BlockIterator;
import block.BlockParser;
import block.HeaderParser;
import block.ImplParser;
import block.Parser;

public class As2ObjC 
{
	private static Map<String, HeaderParser> headers;
	
	public static void main(String[] args) 
	{
		File outputDir = new File(args[0]);		
		
		headers = new HashMap<String, HeaderParser>();
		
		try
		{
			for (int i = 1; i < args.length; ++i)
			{
				File asSourceFile = new File(args[i]);
				process(asSourceFile, outputDir);
			}
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
    }

	private static void process(File file, File outputDir) throws IOException
	{
		if (file.isDirectory())
		{
			File[] files = FileUtils.listFiles(file, ".h", ".m", ".mm");
			
			for (File child : files) 
			{
				process(child, outputDir);
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
		
		Parser parser;
		if (sourceName.endsWith(".h"))
		{
			HeaderParser headerParse = new HeaderParser(iter);
			headers.put(FileUtils.fileNameNoExt(sourceName), headerParse);
			parser = headerParse;
		}
		else
		{
			parser = new ImplParser(iter);
		}
		
		parser.parse();
		
		File outFile = new File(outputDir, source.getName());
		writeCode(outFile, parser.getCodeLines());		
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