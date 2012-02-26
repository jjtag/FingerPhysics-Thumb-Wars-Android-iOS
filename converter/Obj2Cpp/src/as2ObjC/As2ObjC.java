package as2ObjC;

import java.io.File;
import java.io.IOException;
import java.util.List;

import bc.utils.file.FileUtils;
import block.BlockIterator;
import block.BlockParser;
import block.HeaderParser;
import block.ImplParser;
import block.Parser;

public class As2ObjC 
{
	public static void main(String[] args) 
	{
		File outputDir = new File(args[0]);		
		
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
			File[] files = FileUtils.listFiles(file, ".h", ".m", ".mm", ".cpp");
			
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
		
		String code = FileUtils.readFileString(source);
		BlockIterator iter = new BlockIterator(code);
		
		Parser parser;
		if (sourceName.endsWith(".h"))
		{
			parser = new HeaderParser(iter);
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

	private static String extractFileNameNoExt(File file)
	{
		String filename = file.getName();
		int dotIndex = filename.lastIndexOf('.');
		return dotIndex == -1 ? filename : filename.substring(0, dotIndex);
	}
	
	private static String extractPackageName(String code) 
	{
		String token = "package ";
		int start = code.indexOf(token) + token.length();
		int end = code.indexOf("\n", start);
		return code.substring(start, end).trim();
	}
}