package block;

public class RegexHelp
{
	public static final String QUOTE = "\"";
	public static final String SPACE = "\\s+";
	public static final String MBSPACE = "\\s?";
	public static final String NOTSPACE = "\\S*";
	public static final String TIDENTIFIER = group("[\\p{Upper}_$]+[\\p{Upper}\\w\\d_$]*");
	public static final String IDENTIFIER = group("[\\w_$]+[\\w\\d_$]*");
	public static final String ANY = group(".*?");
	public static final String ALL = group(".*");
	public static final String STAR = "\\*";
	public static final String PLUS = "\\+";
	public static final String LPAR = "\\(";
	public static final String RPAR = "\\)";
	public static final String LBRKT = "\\[";
	public static final String RBRKT = "\\]";
	public static final String DOT = "\\.";
	
	public static String group(String str)
	{
		return "(" + str + ")";
	}
	
	public static String mb(String str)
	{
		return group(str) + "?";
	}
	
	public static String few(String str)
	{
		return group(str) + "+";
	}
	
	public static String or(String a, String... other)
	{
		StringBuilder result = new StringBuilder(a);
		for (String o : other)
		{
			result.append("|" + o);
		}
		return result.toString();
	}
}
