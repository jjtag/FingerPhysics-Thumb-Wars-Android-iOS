#ifndef __NSScanner_h__
#define __NSScanner_h__

#include "NSObject.h"

class NSScanner : public NSObject
{
public:
    NSOBJ(NSScanner);

    static NSScanner* scannerWithString(NSString* str);

    virtual void scanHexInt(unsigned int* v);
};

#endif // __NSScanner_h__
