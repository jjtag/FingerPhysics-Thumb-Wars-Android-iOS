//
//  ColoredLayer.m
//  champions
//
//  Created by ikoryakin on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ColoredLayer.h"


@implementation ColoredLayer

-(void)draw
{
	[self preDraw];
	glDisable(GL_TEXTURE_2D);
	drawSolidRectWOBorder(drawX, drawY, width, height, color);
	glEnable(GL_TEXTURE_2D);
	[self postDraw];
}

@end
