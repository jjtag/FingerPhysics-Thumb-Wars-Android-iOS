#ifndef __NSString_h__
#define __NSString_h__

#include "NSObject.h"
#include "NSTypes.h"
#include "stdarg.h"

class NSData;
class NSArray;

#define NSS(x) (NSString::createWithUnicode(L ##x))
#define NSUTF8StringEncoding NSS("utf-8")

// string format helper
//#define FORMAT_STRING(format, args...) stringWithFormat_(format, args)
#define FORMAT_STRING1(format, arg1) NSString::stringWithFormat1(format, arg1)
#define FORMAT_STRING2(format, arg1, arg2) NSString::stringWithFormat2(format, arg1, arg2)
#define FORMAT_STRING3(format, arg1, arg2, arg3) NSString::stringWithFormat3(format, arg1, arg2, arg3)
#define FORMAT_STRING4(format, arg1, arg2, arg3, arg4) NSString::stringWithFormat4(format, arg1, arg2, arg3, arg4)

typedef struct _NSRange {
      NSUInteger location;
      NSUInteger length;
} NSRange;

inline NSRange NSMakeRange(NSUInteger location, NSUInteger length)
{
    NSRange r;
    r.location = location;
    r.length = length;
    return r;
}

class NSString : public NSObject
{
public:
    wchar_t* value;
    int _hash;

public:
    NSString();

    NSOBJ(NSString);

    static NSString* createWithUnicode(const wchar_t* str, int len = -1);

    NSString* initWithAscii(const char* str, int len = -1);
    NSString* initWithUtf8(const char* str, int len = -1);
    NSString* initWithUnicode(const wchar_t* str, int len = -1);
    NSString* initWithString(const NSString* str);
    NSString* initWithDataencoding(NSData* data, NSString* enc);
    NSData* dataUsingEncoding(NSString* enc);

    char* getAsciiCopy(); // Надо не забывать удалит char* после


    bool isEqualToString(const NSString* str);
    virtual bool isEquals(NSObject* obj);
    virtual int hash();

    NSRange rangeOfString(const NSString* str);

    void getCharacters(unichar* buffer);

    NSString* substringWithRange(NSRange range);
    NSString* substringFromIndex(int index);
    NSString* substringToIndex(int index);

    NSString* copy();

    NSArray* componentsSeparatedByString(NSString* str);

    static NSString* stringWithFormat(NSString* format, int const* args);
    static inline NSString* stringWithFormat1(NSString* format, int arg1) { int args[] = { arg1 }; return stringWithFormat(format, args); }
    static inline NSString* stringWithFormat2(NSString* format, int arg1, int arg2) { int args[] = { arg1, arg2 }; return stringWithFormat(format, args); }
    static inline NSString* stringWithFormat3(NSString* format, int arg1, int arg2, int arg3) { int args[] = { arg1, arg2, arg3 }; return stringWithFormat(format, args); }
    static inline NSString* stringWithFormat4(NSString* format, int arg1, int arg2, int arg3, int arg4) { int args[] = { arg1, arg2, arg3, arg4 }; return stringWithFormat(format, args); }

    bool hasSuffix(NSString* suffix);

    unichar characterAtIndex(int index) { return value[index]; }

    int length();

    static NSString* stringWithString(const NSString* str);

    float floatValue();
    int intValue();

    virtual void dealloc();
};

class NSMutableString : public NSString
{
public:
    NSOBJ(NSMutableString);

    virtual void deleteCharactersInRange(NSRange range);
};

#endif // __NSString_h__
