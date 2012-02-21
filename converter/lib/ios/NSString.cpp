#include "NSString.h"
#include <wchar.h>
#include "string.h"
#include "NSArray.h"
#include "NSData.h"

static int wide_len(const wchar_t* str)
{
    int len = 0;
    while (*str++)
        len++;
    return len;
}

static int wide_compare(const wchar_t* str1, const wchar_t* str2)
{
    while (*str1 || *str2)
    {
        int delta = *str1 - *str2;
        if (delta != 0)
            return delta;

        str1++;
        str2++;
    }

    return 0;
}

static wchar_t* wide_find(const wchar_t* from, const wchar_t* what)
{
    while (*from)
    {
        const wchar_t* f = from;
        const wchar_t* w = what;

        while (*w && *f == *w)
        {
            w++;
            f++;
        }

        if (!*w)
            return (wchar_t*)from;
        from++;
    }

    return 0;
}

static void wide_copy(wchar_t* to, const wchar_t* from)
{
    while (*from)
        *to++ = *from++;
    *to = 0;
}

NSString::NSString()
{
    value = new wchar_t[1];
    value[0] = 0;
}

char* NSString::getAsciiCopy()
{
	int len = length();
	char* str = new char[len + 1];
	for (int i = 0; i < len; i++)
		str[i] = (char)value[i];
	str[len] = 0;
	return str;
}

NSString* NSString::createWithUnicode(const wchar_t* str, int len)
{
    return (NSString*)alloc()->initWithUnicode(str, len)->autorelease();
}

NSString* NSString::initWithUnicode(const wchar_t* str, int len)
{
    delete[] value;
    if (len < 0)
        len = wide_len(str);
    value = new wchar_t[len + 1];
    for (int i = 0; i < len; i++)
        value[i] = str[i];
    value[len] = 0;
    return this;
}

NSString* NSString::initWithUtf8(const char* str, int len)
{
	delete[] value;
	// Calc size
	if (len < 0)
	{
		len = 0;
		const char* f = str;
		while (*f)
		{
			int a = (*f++) & 0xff;
			if ((a & 0x80) == 0)
			{
				len++;
			}
			else if ((a & 0xe0) == 0xc0)
			{
				f++;
				len++;
			}
			else if ((a & 0xf0) == 0xe0)
			{
				f += 2;
				len++;
			}
		}
	}

	value = new wchar_t[len + 1];
	const char* f = str;
	for (int i = 0; i < len; i++)
	{
		int a = (*f++) & 0xff;
		if ((a & 0x80) == 0)
		{
			value[i] = (wchar_t)a;
		}
		else if ((a & 0xe0) == 0xc0)
		{
			int b = (*f++) & 0xff;
			value[i] = ((wchar_t)(((a & 0x1F) << 6) | (b & 0x3F)));
		}
		else if ((a & 0xf0) == 0xe0)
		{
			int b = (*f++) & 0xff;
			int c = (*f++) & 0xff;
            value[i] = ((wchar_t)((((a & 0x0F) << 12) | ((b & 0x3F) << 6)) | (c & 0x3F)));
		}
	}
	value[len] = 0;
	return this;
}

NSString* NSString::initWithAscii(const char* str, int len)
{
    delete[] value;
    if (len < 0)
        len = strlen(str);
    value = new wchar_t[len + 1];
    for (int i = 0; i < len; i++)
        value[i] = str[i];
    value[len] = 0;
    return this;
}

NSString* NSString::initWithString(const NSString* str)
{
    delete[] value;
    int len = wide_len(str->value);
    value = new wchar_t[len + 1];
    for (int i = 0; i < len; i++)
        value[i] = str->value[i];
    value[len] = 0;
    return this;
}

bool NSString::isEqualToString(const NSString* str)
{
	if(!this)
		return false;
    return wide_compare(value, str->value) == 0;
}

bool NSString::isEquals(NSObject* obj)
{
	if(!this)
		return false;
    return isEqualToString((NSString*)obj);
}

int NSString::hash()
{
    if (_hash == 0)
    {
        int h = 0;
        int len = length();
        for (int i = 0; i < len; i++)
            h += (int)value[i];
        _hash = h;
    }

    return _hash;
}

NSRange NSString::rangeOfString(const NSString* str)
{
    int strLen = ((NSString*)str)->length();
    NSRange r;
    r.length = 0;
    r.location = 0;

    if (strLen > 0)
    {
        wchar_t* found = wide_find(value, str->value);
        if (found)
        {
            r.length = strLen;
            r.location = found - value;
        }
    }

    return r;
}

NSString* NSString::stringWithString(const NSString* str)
{
    return (NSString*)NSString::alloc()->initWithString(str)->autorelease();
}

int NSString::length()
{
    return wide_len(value);
}

void NSString::getCharacters(unichar* buffer)
{
	wide_copy(buffer,value);
}

NSString* NSString::substringWithRange(NSRange range)
{
	return (NSString*)NSString::alloc()->initWithUnicode(value + range.location, range.length)->autorelease();
}

NSString* NSString::substringFromIndex(int index)
{
	NSUInteger valueLength = length();
	ASSERT(index<=length());
	NSRange rg;
	rg.location = index;
	rg.length = valueLength - index;

    return substringWithRange(rg);
}

NSString* NSString::substringToIndex(int index)
{
	NSUInteger valueLength = length();
	ASSERT(index<=length());
	NSRange rg;
	rg.location = 0;
	rg.length = index;

    return substringWithRange(rg);
}

NSArray* NSString::componentsSeparatedByString(NSString* str)
{
    int idx = 0;
    int len = length();

    wchar_t* sep = str->value;
    int sepLen = str->length();

    NSArray* res = (NSArray*)NSArray::array();

    while (idx < len)
    {
        wchar_t* start = value + idx;
        wchar_t* end = wide_find(start, sep);
        int eidx;
        if (end)
            eidx = idx + (end - start);
        else
            eidx = len;

        NSString* s = (NSString*)NSString::alloc()->initWithUnicode(start, eidx - idx);
        res->addObject(s);
        idx = eidx + sepLen;
    }

    return res;
}

NSString* NSString::stringWithFormat(NSString* format, int const* args)
{
    va_list ap;
    wchar_t* buf = new wchar_t[format->length() + 256];
    wchar_t* t = buf;
    wchar_t* f = format->value;
    int len = format->length();
    int argNo = 0;

    while(true)
    {
        wchar_t ch = *f++;
        if (ch == 0)
        {
            *t++ = 0;
            break;
        }
        else if (ch == '%')
        {
            ch = *f++;

            if (ch == '@')
            {
                NSString* str = (NSString*)args[argNo++];
                wchar_t* x = str->value;
                while (*x)
                    *t++ = *x++;
            }
            else if (ch == 'd')
            {
                int val = args[argNo++];
                if(val<0)
                {
                	*t++ = '-';
                	val = -val;
                }
                int d = 1;
                while (d <= val)
                    d *= 10;

                while (d > 10)
                {
                    d /= 10;
                    int x = val / d;
                    *t++ = '0' + x;
                    val -= x * d;
                }

                *t++ = '0' + val;
            }
            else if(ch == 'f')
            {

            }
            else
            {
                wchar_t* strFormat = f-1;
                int formatCount = 0;
            	while(true)
            	{
            		wchar_t chrFormat = *strFormat;
            		if(chrFormat=='d')
            		{
            			wchar_t filler;
            			strFormat = f - 1;
            			f += formatCount;
            			if(*strFormat=='0')
            			{
            				filler = '0';
            				strFormat++;
            				formatCount--;
            			}
            			else
            				filler = ' ';

            			int filCount = 0;
             			int sign = 1;
            			for(int i = 0; i<formatCount; i++)
            			{
            				if((*strFormat) == L'-')
            				{
            					sign = -1;
            					strFormat++;
            					continue;
            				}
            				filCount = filCount * 10;
            				filCount += (*strFormat++) - '0';
            			}

            			filCount *= sign;
//            			if(filCount > 0)
//            				for(int i = 0; i < filCount;i++)
//            					*t++ = filler;
                        int val = args[argNo++];
                        if(val<0)
                        {
                        	*t++ = '-';
                        	val = -val;
                        }
                        int d = 1;
                        while (d <= val || filCount > 0)
                        {
                            d *= 10;
                            filCount--;
                        }

                        while (d > 10)
                        {
                            d /= 10;
                            int x = val / d;
                            *t++ = '0' + x;
                            val -= x * d;
                        }

                        *t++ = '0' + val;

            			if(filCount < 0)
            				for(int i = 0; i < -filCount;i++)
            					*t++ = filler;

            			break;
            		}
            		else if(((chrFormat>='0')&&(chrFormat<='9'))||(chrFormat=='-'))
            		{
            			formatCount++;
            			chrFormat = *strFormat++;
            		}
            		else
            		{
            			f += formatCount;
            			continue;
            		}
            	}
            }
        }
        else
        {
            *t++ = ch;
        }
    }

    NSString* newString = (NSString*)NSString::alloc()->initWithUnicode(buf)->autorelease();

    delete[] buf;

    return newString;
}

NSString* NSString::initWithDataencoding(NSData* data, NSString* enc)
{
	return nil;
}

bool NSString::hasSuffix(NSString* suffix)
{
	// ADDCODE: add code here
	return false;
}

NSData* NSString::dataUsingEncoding(NSString* enc)
{
	// Calc len
	int len = length();
	int size = 0;
    for (int i = 0; i < len; i++)
    {
        wchar_t ch = value[i];
        if (ch < 0x80)
            size++;
        else if (ch < 0x800)
            size += 2;
        else
            size += 3;
    }

    char* bytes = new char[size + 1];
    char* b = bytes;
    for (int i = 0; i < len; i++)
    {
        wchar_t ch = value[i];
        if (ch < 0x80)
        {
            *b++ = (char)ch;
        }
        else if (ch < 0x800)
        {
            *b++ = (char)(0xc0 | (0x1f & (ch >> 6)));
            *b++ = (char)(0x80 | (0x3f & ch));
        }
        else
        {
            *b++ = (char)(0xe0 | (0x0f & (ch >> 12)));
            *b++ = (char)(0x80 | (0x3f & (ch >> 6)));
            *b++ = (char)(0x80 | (0x3f & ch));
        }
    }

    NSData* data = NSData::alloc();
    data->initWithBytes((void*)bytes, size);

    data->autorelease();

    delete[] bytes;

	return data;
}

NSString* NSString::copy()
{
    return (NSString*)NSString::alloc()->initWithUnicode(value);
}

float NSString::floatValue()
{
	if(!this)
		return 0;
	float v = 0;
	wchar_t* f = value;
	int sign = 1;
	int decMultiplier = 10;
	int fracDivider = 1;
	while (*f )
	{
		if((*f) == L'-')
		{
			sign = -1;
			f++;
			continue;
		}
		if(((*f) == L',')||((*f) == L'.'))
		{
			decMultiplier = 1;
			fracDivider = 10;
			f++;
			continue;
		}
	    v = v * decMultiplier;
	    v += ((float)(*f++) - '0')/fracDivider;
	    if(fracDivider>1)
	    	fracDivider *= 10;
	}

	return v * sign;
}

int NSString::intValue()
{
	if(!this)
		return 0;
	int v = 0;
	wchar_t* f = value;
	int sign = 1;
	while (*f)
	{
		if((*f) == L'-')
		{
			sign = -1;
			f++;
			continue;
		}
	    v = v * 10;
	    v += (*f++) - '0';
	}

	return v * sign;
}

void NSString::dealloc()
{
    if (value)
        delete[] value;
    NSObject::dealloc();
}

//////////////////////////////////////////////////////////////

void NSMutableString::deleteCharactersInRange(NSRange range)
{
	// ADDCODE: add code here
    int b = 1;
}
