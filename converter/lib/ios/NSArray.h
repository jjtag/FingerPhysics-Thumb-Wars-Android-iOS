#ifndef __NSARRAY_H_
#define __NSARRAY_H_


#include "NSObject.h"
#include "List.h"

//class List;

class NSArray: public NSObject
{
private:
    int size;
    int maxSize;
    IID* objs;

public:
	NSOBJ(NSArray)

public:
	virtual void dealloc();

	virtual IID init();

	virtual IID initWithArray(NSArray* array);
	virtual IID initWithObjectscount(IID* objects, NSUInteger count);
	static IID array();
	static IID arrayWithObject(IID object);
	static IID arrayWithArray(NSArray* array);
	static IID arrayWithObjectscount(IID* objects, NSUInteger count);

public:
	// Mutable
	void addObject(NSObject *object);
	void replaceObjectAtIndexWithObject(NSUInteger index, NSObject* object);
	IID objectAtIndex(NSUInteger index);
	void removeObject(NSObject* object);
	void removeObjectAtIndex(NSUInteger index);
	void removeLastObject();
	void removeAllObjects();
	NSUInteger count();
	bool containsObject(NSObject *object);
};

class NSMutableArray : public NSArray
{
public:
    NSOBJ(NSMutableArray);
};

#endif//__NSARRAY_H_
