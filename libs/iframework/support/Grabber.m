/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 On-Core
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "Grabber.h"
#import "Framework.h"

void drawGrabbedImage(Texture2D* t, int x, int y)
{
	GLfloat		coordinates[] = 
	{
		0.0f,	0.0f,
		t->_maxS,	0.0f,
		0.0f,	t->_maxT,
		t->_maxS,	t->_maxT
	};

	GLfloat		vertices[] = {	
		x,			t->_realHeight  + y,	0.0f,
		t->_realWidth + x,	t->_realHeight  + y,	0.0f,
		x,			y,	0.0f,
		t->_realWidth + x,	y,	0.0f,
	};
	
	glBindTexture(GL_TEXTURE_2D, t->_name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@implementation Grabber

-(id) init
{
	if(( self = [super init] )) {
		// generate FBO
		glGenFramebuffersOES(1, &fbo);		
	}
	return self;
}
-(void)grab:(Texture2D*)texture
{
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO);
	
	// bind
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);

	if (texture)
	{
		// associate texture with FBO
		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, texture.name, 0);
	}
	
	// check if it worked (probably worth doing :) )
	GLuint status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
	if (status != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		ASSERT_MSG(FALSE, @"Could not attach texture to framebuffer");
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
}

-(void)beforeRender:(Texture2D*)texture
{	
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFBO);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);
	
	// BUG XXX: doesn't work with RGB565.
	glClearColor(0.0f,0.0f,0.0f,0.0f);

	glClear(GL_COLOR_BUFFER_BIT);
}

-(void)afterRender:(Texture2D*)texture
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
}

- (void) dealloc
{
	glDeleteFramebuffersOES(1, &fbo);
	[super dealloc];
}

@end
