#include "NSTimer.h"
#include "time.h"
#include <unistd.h>

NSTimer::Entry* NSTimer::root = 0;
NSTimer::Entry* NSTimer::tail = 0;
bool NSTimer::needBreak;

void NSTimer::fireTimers()
{
    //clock_t start = clock();

//    needBreak = false;
//
//    while (!needBreak)
    {
//        clock_t now = clock();
//        if ((now - start) > CLOCKS_PER_SEC)
//            break;
//
//        long delta = CLOCKS_PER_SEC;
//
//        Entry* e = root;
//        while (e)
//        {
//            long d = e->fireTime - now;
//            if (delta > d)
//                delta = d;
//            e = e->next;
//        }
//
//        if (delta > 1000)
//            usleep((unsigned long)delta);
//
//        now = clock();

        clock_t now = clock();
        Entry* e = root;
        while (e)
        {
            Entry* ne = e->next;

            if (now >= e->fireTime)
            {
                e->busy = true;
                e->func(e->obj);
                e->busy = false;
                if (e->repeat)
                {
                    e->fireTime = e->fireTime + e->delay;
                    if (e->fireTime < now)
                        e->fireTime = now;
                }
                else
                {
                    removeEntry(e);
                    if (e->kill)
                    {
                        NSREL(e->obj);
                        delete e;
                    }
                }
            }

            e = ne;
        }
    }
}

void NSTimer::addEntry(Entry* entry)
{
    if (!entry->active)
    {
        entry->next = root;
        entry->prev = 0;
        if (root)
            root->prev = entry;
        else
            tail = entry;
        root = entry;

        entry->active = true;
    }
}

void NSTimer::removeEntry(Entry* entry)
{
    if (entry->active)
    {
        if (entry->next)
            entry->next->prev = entry->prev;
        else
            tail = entry->prev;
        if (entry->prev)
            entry->prev->next = entry->next;
        else
            root = entry->next;

        entry->active = false;
    }
}

void NSTimer::removeAllEntries()
{
	Entry* current = root;

	while(current != tail)
	{
		current = current->next;
		if(current->prev->kill)
		{
			NSREL(current->prev->obj);
			delete current->prev;
		}
	}
	if(current->kill)
	{
		NSREL(current->prev->obj);
		delete current->prev;
	}
	root = 0;
	tail = 0;
}

void NSTimer::dealloc()
{
    if (timerEntry)
    {
        if (timerEntry->busy)
        {
            timerEntry->repeat = false;
            timerEntry->kill = true;
        }
        else
        {
            removeEntry(timerEntry);
            NSREL(timerEntry->obj);
            delete timerEntry;
        }
    }
    NSObject::dealloc();
}

void NSTimer::registerDelayedObjectCall(TimerFunc* func, NSObject* obj, CFAbsoluteTime interval)
{
    Entry* entry = new Entry();
    entry->func = func;
    entry->repeat = false;
    entry->obj = NSRET(obj);
    entry->delay = (clock_t)(interval * CLOCKS_PER_SEC);
    entry->fireTime = clock() + entry->delay;
    entry->active = false;
    entry->next = 0;
    entry->prev = 0;
    entry->kill = true;

    addEntry(entry);
}

NSTimer* NSTimer::schedule(TimerFunc* func, NSObject* obj, CFAbsoluteTime interval, bool repeat)
{
    NSTimer* timer = NSTimer::alloc();
    timer->init();

    Entry* entry = new Entry();
    entry->func = func;
    entry->repeat = repeat;
    entry->obj = NSRET(obj);
    entry->delay = (clock_t)(interval * CLOCKS_PER_SEC);
    entry->fireTime = clock() + entry->delay;
    entry->active = false;
    entry->next = 0;
    entry->prev = 0;
    entry->kill = false;
    timer->timerEntry = entry;

    addEntry(entry);

    return timer;
}

//CFAbsoluteTime NSTimer::getAbsoluteTime()
//{
//    clock_t clocks = clock();
//    return clocks / (CFAbsoluteTime) (CLOCKS_PER_SEC);
//}
//
//long NSTimer::getTimeInMillis()
//{
//    clock_t clocks = clock();
//    return (long)(clocks / (CLOCKS_PER_SEC / 1000));
//}
//
//long NSTimer::getTimeInMicros()
//{
//    clock_t clocks = clock();
//    return (long)(clocks / (CLOCKS_PER_SEC / 1000000));
//}
