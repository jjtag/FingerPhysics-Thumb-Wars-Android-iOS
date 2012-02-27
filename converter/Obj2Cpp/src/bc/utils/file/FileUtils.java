package bc.utils.file;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;

public class FileUtils
{
	public static List<String> readFile(File file) throws IOException
	{
		BufferedReader reader = null;
		try
		{
			List<String> lines = new ArrayList<String>();
			reader = new BufferedReader(new FileReader(file));
			String line;
			while ((line = reader.readLine()) != null)
			{
				lines.add(line);
			}
			return lines;
		}
		finally
		{
			if (reader != null)
			{
				reader.close();
			}
		}
	}

	public static String readFileString(File file) throws IOException
	{
		BufferedReader reader = null;
		try
		{
			reader = new BufferedReader(new FileReader(file));
			StringBuilder code = new StringBuilder();

			String line;
			while ((line = reader.readLine()) != null)
			{
				code.append(line);
				code.append("\n");
			}

			return code.toString();
		}
		finally
		{
			if (reader != null)
				reader.close();
		}
	}
	
	public static void writeFile(File file, List<String> lines) throws IOException
	{
		PrintStream out = null; 
		try
		{
			out = new PrintStream(file);
			for (String line : lines)
			{
				out.println(line);
			}
		}
		finally
		{
			if (out != null)
			{
				out.close();
			}
		}
	}
	
	public static File[] listFiles(File file, final String... extensions)
	{
		assert file.isDirectory();
		
		return file.listFiles(new FileFilter()
		{
			@Override
			public boolean accept(File pathname)
			{
				String name = pathname.getName();
				if (pathname.isDirectory())
				{
					return !name.equals(".svn") && !name.equals(".git"); 
				}
				
				for (String ext : extensions)
				{
					if (name.endsWith(ext))
					{
						return true;
					}
				}
				
				return false;
			}
		});
	}
	
	public static String fileNameNoExt(File file)
	{
		return fileNameNoExt(file.getName());
	}
	
	public static String fileNameNoExt(String filename)
	{
		int index = filename.lastIndexOf('.');
		if (index != -1)
		{
			return filename.substring(index);
		}
		return filename;
	}
}
