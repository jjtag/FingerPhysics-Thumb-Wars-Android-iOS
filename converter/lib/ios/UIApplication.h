#ifndef __UIApplication_h__
#define __UIApplication_h__

#include "NSObject.h"

class UIApplication;

class UIApplicationDelegate
{
public:
    virtual void applicationDidFinishLaunching(UIApplication * application) {}

    // ?
    virtual void applicationWillTerminate(UIApplication * application) {}
    virtual void applicationDidReceiveMemoryWarning(UIApplication * application) {}
    virtual void challengeStartedWithGameConfig(NSString* gameConfig) {}
    virtual void applicationWillResignActive(UIApplication * application) {}
    virtual void applicationDidBecomeActive(UIApplication * application) {}
};

class UIView : public NSObject
{
public:
    NSOBJ(UIView);

    virtual IID initWithFrame(CGRect rect) { return init(); }
};

class UIViewController : public NSObject
{
public:
    NSOBJ(UIViewController);
};

class UIApplication : public NSObject
{
public:
    NSOBJ(UIApplication);
};

class UITouch : public NSObject
{
public:
    NSOBJ(UITouch);

    float x;
    float y;

    static UITouch* createWithXY(float _x, float _y) { return (UITouch*)alloc()->initWithXY(_x, _y)->autorelease(); }

    virtual IID initWithXY(float _x, float _y) { NSObject::init(); x = _x, y = _y; return this; }
    virtual CGPoint locationInView(UIView* view) { CGPoint p; p.x = x; p.y = y; return p; }
};

#endif // __UIApplication_h__
