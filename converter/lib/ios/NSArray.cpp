#include "NSArray.h"
#include <malloc.h>

#define INITIAL_SIZE 16

void NSArray::dealloc()
{
    for (int i = 0; i < size; i++)
        NSREL(objs[i]);
    free((void*)objs);
    NSObject::dealloc();
}

IID NSArray::init()
{
    if (!NSObject::init())
        return nil;

    size = 0;
    maxSize = INITIAL_SIZE;
    objs = (IID*)malloc(maxSize * sizeof(IID));

    return this;
}

IID NSArray::initWithArray(NSArray* array)
{
    if (!init())
        return nil;

    int count = array->count();

	for (NSUInteger i = 0; i < count; i++)
	    addObject(array->objectAtIndex(i));

	return this;
}

IID NSArray::initWithObjectscount(IID *objects, NSUInteger count)
{
    if (!init())
        return nil;

	for (int i = 0; i < count; i++)
	    addObject(objects[i]);

	return this;
}

IID NSArray::arrayWithObject(IID object)
{
	return arrayWithObjectscount(&object, 1);
}

IID NSArray::array()
{
	return NSArray::alloc()->init()->autorelease();
}

IID NSArray::arrayWithArray(NSArray* array)
{
	return NSArray::alloc()->initWithArray(array)->autorelease();
}

IID NSArray::arrayWithObjectscount(IID* objects, NSUInteger count)
{
	return NSArray::alloc()->initWithObjectscount(objects, count)->autorelease();
}

void NSArray::addObject(NSObject* object)
{
    if (size >= maxSize)
    {
        maxSize *= 2;
        objs = (IID*)realloc((void*)objs, maxSize * sizeof(IID));
    }

    objs[size++] = NSRET(object);
}

void NSArray::replaceObjectAtIndexWithObject(NSUInteger index, NSObject* object)
{
	ASSERT(index < count()); // index out of bounds

	NSREL(objs[index]);
	objs[index] = NSRET(object);
}

IID NSArray::objectAtIndex(NSUInteger index)
{
	ASSERT(index < count()); // index out of bounds
	return objs[index];
}

void NSArray::removeObject(NSObject* object)
{
    for (int i = 0; i < size; i++)
    {
        if (object->isEquals(objs[i]))
        {
            removeObjectAtIndex(i);
            break;
        }
    }
}

void NSArray::removeObjectAtIndex(NSUInteger index)
{
	ASSERT(index < count()); // index out of bounds

	NSREL(objs[index]);
	for (int i = index + 1; i < size; i++)
	    objs[i - 1] = objs[i];
	size--;
}

void NSArray::removeLastObject()
{
	ASSERT(size != 0);
	removeObjectAtIndex(size - 1);
}

void NSArray::removeAllObjects()
{
    for (int i = 0; i < size; i++)
        NSREL(objs[i]);
    size = 0;
}

NSUInteger NSArray::count()
{
	return size;
}

bool NSArray::containsObject(NSObject* object)
{
    for (int i = 0; i < size; i++)
    {
        if (object->isEquals(objs[i]))
            return true;
    }

    return false;
}
