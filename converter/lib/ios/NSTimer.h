#ifndef __NSTimer_h__
#define __NSTimer_h__

#include "NSObject.h"
#include "NSTypes.h"
#include "time.h"

typedef void TimerFunc(NSObject* obj);

class NSTimer : public NSObject
{
public:
    struct Entry
    {
        clock_t fireTime;
        clock_t delay;
        bool repeat;
        bool active;
        bool kill;
        bool busy;

        TimerFunc* func;
        NSObject* obj;

        Entry* next;
        Entry* prev;
    };

    static Entry* root;
    static Entry* tail;

    static bool needBreak;

    static void addEntry(Entry* entry);
    static void removeEntry(Entry* entry);
    static void removeAllEntries();
    static void fireTimers();
    static void requireBreak() { needBreak = true; }

    static void registerDelayedObjectCall(TimerFunc* func, NSObject* obj, CFAbsoluteTime interval);

public:
    NSOBJ(NSTimer);

    Entry* timerEntry;

    virtual void dealloc();
    virtual void invalidate() { dealloc(); }

    static NSTimer* schedule(TimerFunc* func, NSObject* obj, CFAbsoluteTime interval, bool repeat);

    //static CFAbsoluteTime getAbsoluteTime();
    //static long getTimeInMillis();
    //static long getTimeInMicros();
};

#endif // __NSTimer_h__
