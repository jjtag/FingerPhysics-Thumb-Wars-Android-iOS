#include "NSSet.h"

IID NSSet::init()
{
    if (!NSObject::init())
        return nil;

    back = (NSArray*)NSArray::alloc()->init();
    return this;
}

void NSSet::dealloc()
{
    NSREL(back);
}

void NSSet::addObject(NSObject* object)
{
    if (!back->containsObject(object))
        back->addObject(object);
}

IID NSSet::initWithObjectscount(IID* objects, NSUInteger count)
{
    if (!init())
        return nil;

	for (int i = 0; i < count; i++)
	    addObject(objects[i]);

	return this;
}

IID NSSet::initWithArray(NSArray* array)
{
    if (!init())
        return nil;

    int count = array->count();
    for (int i = 0; i < count; i++)
        addObject(array->objectAtIndex(i));

	return this;
}

IID NSSet::initWithSet(NSSet* set)
{
	NSArray* array = allObjects();
	return initWithArray(array);
}

IID NSSet::set()
{
	return NSSet::alloc()->init()->autorelease();
}

IID NSSet::setWithArray(NSArray* array)
{
	return NSSet::alloc()->initWithArray(array)->autorelease();
}

IID NSSet::setWithSet(NSSet* set)
{
	return NSSet::alloc()->initWithSet(set)->autorelease();
}

IID NSSet::setWithObject(NSObject* object)
{
	return NSSet::alloc()->initWithObjectscount(&object, 1)->autorelease();
}

IID NSSet::setWithObjectscount(IID* objects, NSUInteger count)
{
	return NSSet::alloc()->initWithObjectscount(objects, count)->autorelease();
}

NSUInteger NSSet::count()
{
	return back->count();
}
//NSEnumerator *objectEnumerator();

BOOL NSSet::isEqualToSet(NSSet* set)
{
    if (count() != set->count())
        return false;

    FORIN(NSObject, o, set)
    {
        if (!containsObject(o))
            return false;
    }
    FORINEND;

	return true;
}

NSArray* NSSet::allObjects()
{
    return (NSArray*)NSArray::arrayWithArray(back);
}

IID NSSet::objectAtIndex(NSUInteger index)
{
	ASSERT(index < count()); // index out of bounds
	return back->objectAtIndex(index);
}

BOOL NSSet::containsObject(IID object)
{
    return back->containsObject(object);
}

BOOL NSSet::isSubsetOfSet(NSSet* set)
{
    FORIN(NSObject, o, back)
    {
        if (!set->containsObject(o))
            return false;
    }
    FORINEND;

    return true;
}

BOOL NSSet::intersectsSet(NSSet *set)
{
    FORIN(NSObject, o, back)
    {
        if (set->containsObject(o))
            return true;
    }
    FORINEND;

    return false;
}

void NSSet::removeAllObjects()
{
	back->removeAllObjects();
}
