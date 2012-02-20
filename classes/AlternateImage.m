//
//  AlternateImage.m
//  champions
//
//  Created by ikoryakin on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlternateImage.h"

@implementation AlternateImage

@synthesize mode;

-(void)draw
{
	switch (mode) {
		case MODE_GL_ONE_GL_ONE_MINUS_SRC_ALPHA:
			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
			break;
		case MODE_GL_SRC_ALPHA_GL_ONE_MINUS_SRC_ALPHA:
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			break;
		default:
			break;
	}
	[super draw];
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
}

@end
