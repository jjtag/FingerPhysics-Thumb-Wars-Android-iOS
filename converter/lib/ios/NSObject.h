#ifndef __NSObject_h__
#define __NSObject_h__

#include "config.h"
#include "log.h"
#include "malloc.h"
#include "ios/NSTypes.h"

#include <memory.h>
#include <strings.h>

#define ASSERT(x)
#define ASSERT_MSG(x,y)
#define LOG_GROUP(x,y)
//#define bzero(b,len) (memset((b), '\0', (len)), (void) 0)
#define MAX(a,b) (((a) > (b)) ? (a) : (b))
#define MIN(a,b) (((a) < (b)) ? (a) : (b))

#define FORIN(type, param, arr) {if(arr) {int count_##param_##arr = arr->count();\
	for (int i_##param_##arr = 0; i_##param_##arr < count_##param_##arr; i_##param_##arr++) \
	{type* param = (type*)arr->objectAtIndex(i_##param_##arr); if (param)

#define FORINEND }}}

/////////////////////////////////////////////////////////////////////

class NSString;
class NSObject;

typedef NSObject* IID;
typedef int NSInteger;
typedef unsigned int NSUInteger;

//#define NULL ((IID)(void*)0)
#define nil 0
#define TRUE true
#define FALSE false

#define NSOBJ(type) \
    static type* alloc() { return new type(); } \
    static type* create() { return (type*)alloc()->init()->autorelease(); } \
    static type* allocAndAutorelease() { return (type*)alloc()->autorelease(); }

#define NSREL(x) if (x) x->release()
#define NSRET(x) (x ? x->retain() : x)

class NSObject
{
public:
    virtual ~NSObject();

    NSOBJ(NSObject);

    virtual void dealloc();

    //IID self();

    virtual IID init();

    virtual IID retain();
    virtual void release();
    virtual IID autorelease();
    NSUInteger retainCount() { return _retainCount; }

    virtual bool isEquals(NSObject* obj);
    virtual int hash();

    void* operator new(size_t sz);
    void operator delete(void* obj);

//    NSObject operator->() const
//    {
//        if (this == 0)
//        {
//            int b = 1;
//        }
//        return *this;
//    }

protected:
    NSObject();

private:

    NSUInteger _retainCount;
};

#include "NSString.h"

#endif // __NSObject_h__
