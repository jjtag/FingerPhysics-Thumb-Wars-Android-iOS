//
//  Parallax.m
//  frameworkTest
//
//  Created by reaxion on 20.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Parallax.h"
#import "Debug.h"

@implementation Parallax
-(id) initWithXPos:(float) xpos YPos:(float) ypos parallaxRatioX:(float) prX parallaxRatioY:(float) prY image:(Texture2D*) image vertAliasing:(bool) vA reverseDirection:(bool) rA;
{
	self = [super init];
	[self setXPos:xpos YPos: ypos];
	parallaxRatioX = prX;
	parallaxRatioY = prY;
	ASSERT(!img);
	img = [image retain];
	vertAliasing = vA;
	reverseDirect = rA;
	return self;
}
-(void)drawWithOffsetX:(float) offsetX offsetY:(float) offsetY
{
	if(reverseDirect)
	{
		offsetX = offsetX * -1;
		offsetY = offsetY * -1;
	}
	glColor4f(1.0, 1.0, 1.0, 1.0);
	if (vertAliasing)
	{
		drawImage(img, x+(offsetX*parallaxRatioX), y-((offsetY+expf(fabsf(offsetX)))*parallaxRatioY));
	}
	else
		drawImage(img, x+(offsetX*parallaxRatioX), y-(offsetY*parallaxRatioY));
	
}

-(void) setXPos:(float) xpos YPos:(float) ypos
{
	x = xpos;
	y = ypos;
}

-(void)dealloc
{
	[img release];
	[super dealloc];
}
@synthesize x, y, parallaxRatioX, parallaxRatioY;
@end
