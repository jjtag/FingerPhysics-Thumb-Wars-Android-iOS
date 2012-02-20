//
//  FPScrollbarContainer.m
//  champions
//
//  Created by ikoryakin on 6/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FPScrollableContainer.h"


@implementation FPScrollableContainer

-(id)initWithWidth:(float)w Height:(float)h ContainerWidth:(float)cw Height:(float)ch
{
	if(self = [super initWithWidth:w Height:h ContainerWidth:cw Height:ch])
	{
		mover = nil;
	}
	return self;
}

-(void)dealloc
{
	if(mover)
		[mover release];
	[super dealloc];
}

-(void)moveToScrollPoint:(int)p
{
	if(!mover)
	{
		mover = [[Mover alloc] initWithPathCapacity:2 MoveSpeed:800 RotateSpeed:0];
		Vector startPoint = vect(container->x, container->y);
		[mover addPathPoint:startPoint];
		[mover addPathPoint:spoints[p]];
		[mover start];
	}
}

-(void)update:(TimeType)delta
{
	[super update:delta];
	if(mover)
	{
		[mover update:delta];

		[self setScroll:vectNeg(mover->pos)];
		if(vectEqual(mover->pos, mover->path[mover->pathLen-1]))
		{
			[mover release];
			mover = nil;
		}
	}
}

@end
