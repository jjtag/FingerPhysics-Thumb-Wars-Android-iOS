//
//  Hash.h
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// implementation of dynamic array
// we retain all objects and release them at dealloc like NSArray
// why we use this instead of NSArray:
// - this allows us to create arrays of given size (capacity)
// - this should be faster
// - this gives us more control in memory allocation

// we adopt NSFastEnumeration protocol to allow array iteration in for..in structures
@interface DynamicArray : NSObject <NSFastEnumeration>
{
@public
	id* map;
	int size;
	
	// highest index at which we have set an element (this may not be equal to size)
	int highestIndex;

@protected
	// how many elements to over-realloc after we reach the array boundary, default is 0
	int overRealloc;	
	// used for fast enumeration
	unsigned long mutationsCount;
}

// basic operations
-(id)init;
-(id)initWithCapacity:(int)c;
-(id)initWithCapacity:(int)c andOverReallocValue:(int)v;
-(void)setObject:(id)obj At:(int)k;
-(int)addObject:(id)obj;
-(id)objectAtIndex:(int)k;
-(void)unsetObjectAtIndex:(int)k;
-(void)unsetAll;
-(void)insertObject:(id)obj atIndex:(int)k;
-(void)removeObjectAtIndex:(int)k;
-(void)removeObject:(id)obj;
-(void)removeAllObjects;
-(int)count;
-(int)capacity;
-(void)setNewSize:(int)k;

// returns index of the first nil element
-(int)getFirstEmptyIndex;
-(int)getObjectIndex:(id)obj;

-(void)dealloc;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

@end
