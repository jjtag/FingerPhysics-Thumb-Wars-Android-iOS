#ifndef __NSData_h__
#define __NSData_h__

#include "NSObject.h"

#include <jni.h>
void initDataJni(jobject _loader);

class NSData : public NSObject
{
public:
    NSOBJ(NSData);

public:
    char* bytes;
    NSUInteger length;

public:
    virtual void dealloc();

    virtual IID initWithData(NSData* data);
    virtual IID initWithContentsOfFile(NSString* path);

    virtual IID initWithBytes(void* data, int len);

    static IID dataWithData(NSData* data);
    static IID dataWithContentsOfFile(NSString* path);

    virtual BOOL isEqualToData(NSData *data);

    virtual void getBytesrange(void* result, NSRange range);
    virtual void getByteslength(void* result, NSUInteger length);
    virtual void getBytes(void* result);
};

#endif // __NSData_h__



//enum {
//   NSDataWritingAtomic=0x01,
//
//// deprecated
//   NSAtomicWrite=NSDataWritingAtomic,
//};
//
//typedef NSUInteger NSDataWritingOptions;
//
//enum {
//   NSDataSearchBackwards=0x01,
//   NSDataSearchAnchored =0x02,
//};
//typedef NSUInteger NSDataSearchOptions;
//
//@interface NSData : NSObject <NSCopying,NSMutableCopying,NSCoding>
//
//-initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone;
//-initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
//-initWithBytes:(const void *)bytes length:(NSUInteger)length;
//-initWithData:(NSData *)data;
//-initWithContentsOfFile:(NSString *)path;
//-initWithContentsOfMappedFile:(NSString *)path;
//-initWithContentsOfURL:(NSURL *)url;
//-initWithContentsOfFile:(NSString *)path options:(NSUInteger)options error:(NSError **)errorp;
//-initWithContentsOfURL:(NSURL *)url options:(NSUInteger)options error:(NSError **)errorp;
//
//+data;
//+dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeWhenDone;
//+dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
//+dataWithBytes:(const void *)bytes length:(NSUInteger)length;
//+dataWithData:(NSData *)data;
//+dataWithContentsOfFile:(NSString *)path;
//+dataWithContentsOfMappedFile:(NSString *)path;
//+dataWithContentsOfURL:(NSURL *)url;
//+dataWithContentsOfFile:(NSString *)path options:(NSUInteger)options error:(NSError **)errorp;
//+dataWithContentsOfURL:(NSURL *)url options:(NSUInteger)options error:(NSError **)errorp;
//
//-(const void *)bytes;
//-(NSUInteger)length;
//
//-(BOOL)isEqualToData:(NSData *)data;
//
//-(void)getBytes:(void *)result range:(NSRange)range;
//-(void)getBytes:(void *)result length:(NSUInteger)length;
//-(void)getBytes:(void *)result;
//
//-(NSData *)subdataWithRange:(NSRange)range;
//
//-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically;
//-(BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically;
//-(BOOL)writeToFile:(NSString *)path options:(NSUInteger)options error:(NSError **)errorp;
//-(BOOL)writeToURL:(NSURL *)url options:(NSUInteger)options error:(NSError **)errorp;
//
//
//-(NSString *)description;
//
//@end
