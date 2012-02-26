//
//  Image.m
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Image.h"
#import "Framework.h"

const NSString* ACTION_SET_DRAWQUAD = @"ACTION_SET_DRAWQUAD";

@implementation Image

@synthesize texture;

+(Image*)create:(Texture2D*)t
{
	return [[[[self class] alloc] initWithTexture:t] autorelease];
}

+(Image*)createWithResID:(int)r
{
	return [[self class] create:[[Application sharedResourceMgr] getResource:r]];
}

+(Image*)createWithResID:(int)r Quad:(int)q
{
	Image* image = [[self class] create:[[Application sharedResourceMgr] getResource:r]];
	[image setDrawQuad:q];
	return image;
}

-(id)initWithTexture:(Texture2D*)t
{
	if (self = [super init])
	{
		ASSERT(t);
		texture = t;
		[texture retain];

		restoreCutTransparency = FALSE;
		
		if (texture->quadsCount > 0)
		{
			[self setDrawQuad:0];
		}
		else
		{
			[self setDrawFullImage];
		}
	}
	
	return self;
}

-(void)setDrawFullImage
{
	quadToDraw = UNDEFINED;
	width = texture.realWidth;
	height = texture.realHeight;	
}

-(void)setDrawQuad:(int)n
{	
	ASSERT(n >= 0 && n < texture->quadsCount);
	quadToDraw = n;
	
	// don't set width / height to quad size if we cutted transparency from each quad
	if (!restoreCutTransparency)
	{
		width = texture->quadRects[n].w;
		height = texture->quadRects[n].h;
	}
}

-(void)doRestoreCutTransparency
{
	if (texture->preCutSize.x != vectUndefined.x)
	{
		restoreCutTransparency = TRUE;
		width = texture->preCutSize.x;
		height = texture->preCutSize.y;
	}
}

-(void)draw
{
	[self preDraw];
	if (quadToDraw == UNDEFINED)
	{
		drawImage(texture, drawX, drawY);
	}
	else
	{
		[self drawQuad:quadToDraw];
	}
	[self postDraw];	
}

-(void)drawQuad:(int)n
{
	ASSERT(n >= 0 && n < texture->quadsCount);
	float quadWidth = texture->quadRects[n].w;
	float quadHeight = texture->quadRects[n].h;

	float qx = drawX;
	float qy = drawY;
	
	if (restoreCutTransparency)
	{
		qx += texture->quadOffsets[n].x;
		qy += texture->quadOffsets[n].y;
	}
	
	GLfloat vertices[] = {	
		qx, qy,
		qx + quadWidth, qy,
		qx, qy + quadHeight,
	qx + quadWidth, qy + quadHeight };	
	
	glBindTexture(GL_TEXTURE_2D, [texture name]);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, &texture->quads[n]);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(bool)handleAction:(ActionData)a
{
	if ([super handleAction:a])
	{
		return TRUE;
	}
	
	if ([a.actionName isEqualToString:(NSString*)ACTION_SET_DRAWQUAD])
	{
		[self setDrawQuad:a.actionParam];
	}
	else
	{
		return FALSE;
	}
	
	return TRUE;
}

+(BaseElement*)createFromXML:(XMLNode*)xml
{
	XML_ASSERT_ATTR(@"src", xml);
	int r = [xml intAttr:@"src"];
	Image* element = [Image create:[[Application sharedResourceMgr] getResource:r]];

	if ([xml hasAttr:@"quadToDraw"])
	{
		int q = [xml intAttr:@"quadToDraw"];
		element->quadToDraw = q;
	}		
	
	return element;
}

-(void)dealloc
{
	[texture release];
	[super dealloc];
}

@end
