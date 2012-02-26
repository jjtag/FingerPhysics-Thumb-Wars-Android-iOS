//
//  View.m
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "View.h"
#import "Debug.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@implementation View

+(View*)create
{
	return [[[[self class] alloc] initFullscreen] autorelease];
}

-(id)initFullscreen
{
	if (self = [super init]);
	{		
		width = SCREEN_WIDTH;
		height = SCREEN_HEIGHT;
	}
	return self;
}

-(void)draw
{
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);		

	[super preDraw];	
	[super postDraw];
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
}

@end
