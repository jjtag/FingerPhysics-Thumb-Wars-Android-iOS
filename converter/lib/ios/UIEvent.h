#ifndef __UIEvent_h__
#define __UIEvent_h__

#include "NSObject.h"
#include "NSSet.h"
#include "UIApplication.h"

class UIEvent : public NSObject
{
public:
    NSOBJ(UIEvent);

    virtual NSSet* allTouches()
    {
        UITouch* touch = UITouch::createWithXY(0, 0);
        NSSet* set = (NSSet*)NSSet::setWithObject(touch);
        return set;
    }
};

#endif // __UIEvent_h__
