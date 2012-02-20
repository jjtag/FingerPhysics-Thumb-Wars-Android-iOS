//
//  LevelSet.m
//  champions
//
//  Created by ikoryakin on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LevelSet.h"


@implementation LevelSet
@synthesize name;

-(id)init
{
	if(self = [super init])
	{
		list = [[DynamicArray alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
	[list release];
}

@end
