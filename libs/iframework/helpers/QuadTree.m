//
//  QuadTree.m
//  rogatka
//
//  Created by Efim Voinov on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QuadTree.h"
#import "Debug.h"

@implementation QuadTree

-(id)initWithSpaceWidth:(int)w Height:(int)h andDrillDownLevels:(int)l
{
	if (self = [super init])
	{
		spaceWidth = w;
		spaceHeight = h;
		drillDownLevels = l;
		
		tree = malloc(sizeof(QuadTreeNode));
		tree->parent = nil;
		tree->bounds = MakeRectangle(0, 0, spaceWidth, spaceHeight);
		[self createChildsForParent:tree atLevel:0];
	}
	
	return self;
}

-(void)createChildsForParent:(QuadTreeNode*)p atLevel:(int)l
{
	p->childs = malloc(sizeof(QuadTreeNode*) * 4);	
	for (int i = 0; i < 4; i++)
	{
		QuadTreeNode* n = malloc(sizeof(QuadTreeNode));		
		n->parent = p;
		p->childs[i] = n;		
		
		int totalLeafsInARow = 2 ^ (l + 1);
		float leafWidth = spaceWidth / totalLeafsInARow;
		float leafHeight = spaceHeight / totalLeafsInARow;
		n->bounds = MakeRectangle(p->bounds.x + leafWidth * (i % 2), p->bounds.y + leafHeight * (i / 2), leafWidth, leafHeight);
		
		if (l + 1 < drillDownLevels)
		{
			[self createChildsForParent:n atLevel:(l + 1)];			
		}
	}
}
		
-(void)addObject:(id)obj toNode:(QuadTreeNode*)n
{
	listAdd(&n->objects, obj);
	[obj retain];
}

-(void)removeObject:(id)obj fromNode:(QuadTreeNode*)n
{
	listRemove(listSearch(&n->objects, obj));
	[obj release];
}

-(void)deleteNode:(QuadTreeNode*)n
{
	ASSERT(n);

	if (n->childs)
	{
		for (int i = 0; i < 4; i++)
		{
			[self deleteNode:n->childs[i]];
		}
	}
	
	ListNode* objectList = n->objects;
	while (objectList)
	{
		[objectList->obj release];
		objectList = objectList->next;
	}
	
	free(n);	
}

-(void)dealloc
{
	[self deleteNode:tree];
	[super dealloc];
}

@end
