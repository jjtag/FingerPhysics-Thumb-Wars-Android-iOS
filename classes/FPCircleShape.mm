//
//  FPCircleShape.m
//  champions
//
//  Created by ikoryakin on 3/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "FPCircleShape.h"

@implementation FPCircleShape

@synthesize radius;

-(id)copyWithZone:(NSZone *)zone
{
	FPCircleShape* copy = [super copyWithZone:zone];
	copy.radius = radius;
	return copy;
}

@end
