#ifndef __NSSet_h__
#define __NSSet_h__

#include "NSObject.h"
#include "List.h"
#include "NSArray.h"

class NSSet: public NSObject
{
public:
    NSArray* back;

public:
	NSOBJ(NSSet);

	virtual IID init();
	virtual void dealloc();


	virtual IID initWithObjectscount(IID *objects, NSUInteger count);
	virtual IID initWithArray(NSArray *array);
	virtual IID initWithSet(NSSet *set);

	static IID set();
	static IID setWithArray(NSArray *array);
	static IID setWithSet(NSSet *set);
	static IID setWithObject(IID object);
	static IID setWithObjectscount(IID *objects, NSUInteger count);


	IID objectAtIndex(NSUInteger index);
	virtual NSUInteger count();
	void addObject(NSObject* object);

	virtual bool isEqualToSet(NSSet *set);

	virtual NSArray *allObjects();

	virtual bool containsObject(IID object);
	virtual bool isSubsetOfSet(NSSet *set);

	virtual bool intersectsSet(NSSet *set);

	virtual void removeAllObjects();

	//virtual (void)makeObjectsPerformSelector(SEL)selector;
	//virtual (void)makeObjectsPerformSelector(SEL)selector withObject:argument;
};
#endif //__NSSet_h__
