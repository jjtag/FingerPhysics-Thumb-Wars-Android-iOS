//
//  MenuView.m
//  blockit
//
//  Created by Mac on 02.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MenuView.h"
#import "Framework.h"

@implementation MenuView

-(void)draw
{
	glClear(GL_COLOR_BUFFER_BIT);
	glColor4f(1.0, 1.0, 1.0, 1.0);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);		
	
	[super preDraw];	
	[super postDraw];
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	
}
@end
