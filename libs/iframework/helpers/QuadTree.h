//
//  QuadTree.h
//  rogatka
//
//  Created by Efim Voinov on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MathHelper.h"
#import "List.h"

// Quad tree implementation
//
// Useful in broad-phase collision detection, culling and other cases (2D)
typedef struct QuadTreeNode
{
	struct QuadTreeNode* parent;
	struct QuadTreeNode** childs;
	ListNode* objects;
	Rectangle bounds;
} QuadTreeNode;

@interface QuadTree : NSObject 
{
	float spaceWidth;
	float spaceHeight;
	int drillDownLevels;
@public
	QuadTreeNode* tree;
}
-(id)initWithSpaceWidth:(int)w Height:(int)h andDrillDownLevels:(int)l;
-(void)addObject:(id)obj toNode:(QuadTreeNode*)n;
-(void)removeObject:(id)obj fromNode:(QuadTreeNode*)n;

-(void)createChildsForParent:(QuadTreeNode*)p atLevel:(int)l;
@end
