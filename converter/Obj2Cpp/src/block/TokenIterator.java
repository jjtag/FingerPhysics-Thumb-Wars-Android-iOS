package block;

public class TokenIterator
{
	private int index;
	private String str;
	
	public TokenIterator(String str)
	{
		this.str = str;
	}
	
	public String captureUntilChar(String str, char stopChar)
	{
		return captureUntilChar(str, stopChar, true);
	}
	
	public String captureUntilChar(String str, char stopChar, boolean skipStopChar)
	{
		boolean insideString = false;
		char prevChar = 0;
		
		StringBuilder token = new StringBuilder();
		
		int parentnessisCounter = 0;
		int bracketCounter = 0;
		boolean insideComment = false;
		
		for (; index < str.length(); ++index)
		{
			char chr = str.charAt(index);
			if (chr == ' ' && token.length() == 0)
			{
				continue; // skip leading spaces
			}
			
			if (chr == '"' && prevChar != '\\')
			{
				insideString = !insideString;
			}
			
			if (!insideString)
			{	
				if (chr == '*' && prevChar == '/')
				{
					insideComment = true;
				}
				else if (chr == '/' && prevChar == '*')
				{
					insideComment = false;
				}
				
				if (insideComment)
				{
					continue; // ignore the inner comment
				}
				
				if (chr == '[')
				{
					bracketCounter++;
				}
				else if (chr == ']')
				{
					assert bracketCounter > 0;
					bracketCounter--;
				}
				else if (chr == '(')
				{
					parentnessisCounter++;
				}
				else if (chr == ')')
				{
					assert parentnessisCounter > 0;
					parentnessisCounter--;
				}
			
				if (chr == stopChar && parentnessisCounter == 0 && bracketCounter == 0)
				{
					if (skipStopChar)
					{
						index++;
					}
					return token.toString();
				}
			}			

			token.append(chr);
			prevChar = chr;
		}

		assert !insideString;
		assert !insideComment;		
		assert parentnessisCounter == 0;
		assert bracketCounter == 0;
		
		return token.toString();
	}
	
	public boolean canCapture()
	{
		return index < str.length();
	}
}
