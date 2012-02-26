//
//  GLAnimationsPool.m
//  rogatka
//
//  Created by Efim Voinov on 06.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AnimationsPool.h"
#import "Framework.h"

@implementation AnimationsPool

-(id)init
{
	if (self = [super init])
	{
		removeList = [[DynamicArray alloc] init];
	}
	
	return self;
}

-(void)update:(TimeType)delta
{
	int count = [removeList count];
	for (int i = 0; i < count; i++)
	{
		[childs removeObject:[removeList objectAtIndex:i]];
	}
	[removeList unsetAll];
	
	[super update:delta];
}

-(void)timeline:(Timeline*)t reachedKeyFrame:(KeyFrame*)k withIndex:(int)i
{
}

-(void)timelineFinished:(Timeline*)e
{
	[removeList addObject:e->element];
}

-(void)particlesFinished:(Particles*)p
{
	[removeList addObject:p];
}

-(void)dealloc
{
	[removeList release];
	[super dealloc];
}


@end
