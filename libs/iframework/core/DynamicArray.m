//
//  Hash.m
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DynamicArray.h"
#import "Debug.h"
#import "Framework.h"

#define DEFAULT_CAPACITY 10

@implementation DynamicArray

-(id)init
{
	if (self = [self initWithCapacity:DEFAULT_CAPACITY andOverReallocValue:DEFAULT_CAPACITY])
	{		
	}
	return self;
}

-(id)initWithCapacity:(int)c;
{
	if (self = [super init])
	{
		ASSERT(c > 0);
		size = c;
		highestIndex = -1;
		overRealloc = 0;
		mutationsCount = 0;
		LOG_GROUP(MEM, FORMAT_STRING(@"Initing %d size dynamic array", size));
		map = malloc(sizeof(id) * size);
		ASSERT(map);
		memset(map, 0, sizeof(id) * size);
		LOG_GROUP(MEM, @"...Inited");		
	}
	
	return self;
}

-(id)initWithCapacity:(int)c andOverReallocValue:(int)v
{	
	if (self = [self initWithCapacity:c])
	{
		overRealloc = v;
	}
		
	return self;
}

// adopted from NSFastEnumeration protocol
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	int num = [self count];
	
	if (state->state >= num)
    {
        return 0;
    }
	
    state->itemsPtr = map;
    state->state = num;
    state->mutationsPtr = (unsigned long *)&mutationsCount;
    
    return num;
}
		
-(int)count
{
	return highestIndex + 1;
}
		
-(int)capacity
{
	return size;	
}
		
-(void)setNewSize:(int)k
{
	int newSize = k + overRealloc;
	map = realloc(map, sizeof(id) * newSize);
	ASSERT(map);
	bzero(map + size, (newSize - size) * sizeof(id));
	size = newSize;
}

-(int)addObject:(id)obj
{
	int index = highestIndex + 1;
	[self setObject:obj At:index];
	return index;
}
		
-(void)setObject:(id)obj At:(int)k
{	
	if (k >= size)
	{
		[self setNewSize:k + 1];
	}
	
	ASSERT_MSG(k >= 0 && k < size, FORMAT_STRING(@"k = %d, size = %d", k, size));

	if (map[k])
	{
		[map[k] release];
	}
	
	if (highestIndex < k)
	{
		highestIndex = k;
	}
	
	map[k] = obj;
	[map[k] retain];

	mutationsCount++;
}

-(id)objectAtIndex:(int)k
{
	ASSERT_MSG(k >= 0 && k < size, FORMAT_STRING(@"k = %d, size = %d", k, size));
	return map[k];
}

-(void)unsetAll
{
	for(int i = 0; i <= highestIndex; i++)
	{
		if (map[i])
		{
			[self unsetObjectAtIndex:i];
		}
	}
}

-(void)unsetObjectAtIndex:(int)k
{
	ASSERT_MSG(k >= 0 && k < size, FORMAT_STRING(@"k = %d, size = %d", k, size));

	ASSERT(map[k]);	
	[map[k] release];
	map[k] = nil;
	
	mutationsCount++;
}

-(void)insertObject:(id)obj atIndex:(int)k
{
	if (k >= size || highestIndex + 1 >= size)
	{
		[self setNewSize:size + 1];
	}
	highestIndex++;
	ASSERT_MSG(k >= 0 && k < size, FORMAT_STRING(@"k = %d, size = %d", k, size));

	
	for (int i = highestIndex; i > k; i--)
	{
		map[i] = map[i - 1];
	}

	map[k] = obj;
	[map[k] retain];	
	
	mutationsCount++;	
}

-(void)removeObjectAtIndex:(int)k
{
	ASSERT_MSG(k >= 0 && k < size, FORMAT_STRING(@"k = %d, size = %d", k, size));

	id oldObj = map[k];
	if (oldObj)
	{
		[oldObj release];
	}
	
	for (int i = k; i < highestIndex; i++)
	{
		map[i] = map[i + 1];
	}

	ASSERT(map[highestIndex] != nil);
	map[highestIndex] = nil;
	
	highestIndex--;
	
	mutationsCount++;		
}

-(void)removeAllObjects
{
	[self unsetAll];
	highestIndex = -1;
}

-(void)removeObject:(id)obj
{
	for (int i = 0; i <= highestIndex; i++)
	{
		if (map[i] == obj)
		{
			[self removeObjectAtIndex:i];
			break;
		}
	}
}

-(int)getFirstEmptyIndex
{
	for (int i = 0; i < size; i++)
	{
		if (map[i] == nil)
		{
			return i;
		}
	}
	
	return size;
}

-(int)getObjectIndex:(id)obj
{
	for (int i = 0; i < size; i++)
	{
		if (map[i] == obj)
		{
			return i;
		}
	}
	
	return UNDEFINED;
}

-(void)dealloc
{
	LOG_GROUP(MEM, FORMAT_STRING(@"freeing %d objects of dynamic array", size));
	for(int i = 0; i <= highestIndex; i++)
	{
		if (map[i])
		{
			LOG_GROUP(MEM, FORMAT_STRING(@"- object %d released", i));
			[map[i] release];
		}
	}
	
	free(map);
	[super dealloc];
}

@end
