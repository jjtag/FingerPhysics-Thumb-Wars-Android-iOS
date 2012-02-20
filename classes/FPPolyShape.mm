//
//  FPPolyShape.m
//  champions
//
//  Created by ikoryakin on 3/16/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "FPPolyShape.h"

static int verts = 0;
@implementation FPPolyShape

@synthesize vertices;

-(id)init
{
	if(self = [super init])
	{
		vertices = [[DynamicArray alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[vertices release];
	[super dealloc];
}

-(id)copyWithZone:(NSZone *)zone
{
	FPPolyShape* copy = [super copyWithZone:zone];	
//	copy.vertices = [[DynamicArray alloc] init];	
	for(int i = 0; i < [vertices count]; i++)
	{
		[copy.vertices addObject:[[[vertices objectAtIndex:i] copy] autorelease]];
	}
	return copy;
}

@end
