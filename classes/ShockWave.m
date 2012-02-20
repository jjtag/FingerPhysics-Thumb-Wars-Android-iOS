//
//  ShockWave.m
//  blockit
//
//  Created by Alexander Roslyakov on 6/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ShockWave.h"
#import "Framework.h"

@implementation ShockWave

-(id)initWith:(Vector)pos andWidth:(float)width andImpulseFactor:(float)impulseFactor;
{
	if(self = [super init])
	{		
		self->position = pos;
		self->initialRadius = width;
		self->currentRadius = width;
		self->initialImpulse = impulseFactor;
		color = (RGBAColor)RGBA_FROM_HEX(255, 132, 28, 255);
	}
	return self;
}

-(void) draw
{
	Vector c = self->position;
	float r1 = self->currentRadius;
	float r2 = r1 - self->initialRadius;
	
	int numVerts = 15;
	drawCircle(c.x, c.y, r1, numVerts*2, color);

	if(r2 > 0)
		drawCircle(c.x, c.y, r2, numVerts*2, color);
}

@end
