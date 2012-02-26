//
//  GLBulletScrollbar.m
//  template
//
//  Created by Efim Voinov on 06.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BulletScrollbar.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Debug.h"
#import "GLDrawer.h"
#import "Texture2D.h"

#define BULLET_OFFSET 5.0
#define BULLET_OPACITY 0.5
#define BULLET_VERTEX_COUNT 14
@implementation BulletScrollbar

-(id)initWithBulletTexture:(Texture2D*)t andTotalBullets:(int)tb
{	
	ASSERT(!bullet);
	bullet = [t retain];

	height = bullet.realHeight;
	width = tb * (bullet.realWidth / 2 + BULLET_OFFSET) - BULLET_OFFSET;
	
	if (self = [super initWithWidth:width Height:height Vertical:FALSE])
	{		
	}
	
	return self;
	
}

-(void)dealloc
{
	[bullet release];
	[super dealloc];
}

-(void)draw
{
	[self preDraw];

	int bullets = (int)(sc.x);
	float mult = (mp.x != 0) ? sp.x / mp.x : 1.0;
	int sbullet = round((float)(bullets - 1) * mult);
		
	float cd = bullet.realWidth / 2;
	
	float sx = drawX;
	float sy = drawY;
	
	for (int i = 0; i < bullets; i++)
	{
		if (i == sbullet)
		{
			drawImagePart(bullet, MakeRectangle(cd, 0, cd, bullet.realHeight), sx , sy);
		}
		else
		{
			drawImagePart(bullet, MakeRectangle(0, 0, cd, bullet.realHeight), sx , sy);
		}
		
		sx += cd + BULLET_OFFSET;
	}
	
	[self postDraw];
}

@end
