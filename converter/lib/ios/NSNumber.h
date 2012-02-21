#ifndef __NSNumber_h__
#define __NSNumber_h__

#include "NSObject.h"

class NSNumber : public NSObject
{
public:
    NSOBJ(NSNumber);

    static NSNumber* numberWithInt(int v);

    virtual int intValue();

public:
    int _value;
};

#endif // __NSNumber_h__
