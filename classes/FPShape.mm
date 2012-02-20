//
//  FPShape.m
//  champions
//
//  Created by ikoryakin on 3/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "FPShape.h"


@implementation FPShape

@synthesize offset;
@synthesize angle, friction, density, restitution;
@synthesize isSensor, isVisible;

-(id)copyWithZone:(NSZone *)zone
{
	FPShape* copy = [[[self class] allocWithZone:zone] init];
	copy.angle = angle;
	copy.density = density;
	copy.friction = friction;
	copy.isSensor = isSensor;
	copy.isVisible = isVisible;
	copy.offset = offset;
	copy.restitution = restitution;
	return copy;
}

-(void)copyAttributesFrom:(FPShape*)shape
{
	angle = shape.angle;
	density = shape.density;
	friction = shape.friction;
	isSensor = shape.isSensor;
	isVisible = shape.isVisible;
	offset = shape.offset;
	restitution = shape.restitution;	
}

-(void)dealloc
{
	if(texels)
		free(texels);
	[super dealloc];
}

@end
