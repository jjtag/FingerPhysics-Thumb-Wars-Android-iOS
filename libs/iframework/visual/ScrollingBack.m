//
//  GLTiledImage.m
//  rogatka
//
//  Created by Efim Voinov on 15.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ScrollingBack.h"
#import "Framework.h"

@implementation ScrollingBack

-(id)initWithImage:(Texture2D*)i Rows:(int)r Columns:(int)c maxCameraWidth:(float)maxW Height:(float)maxH
{
	cameraWidth	= SCREEN_WIDTH;
	cameraHeight = SCREEN_HEIGHT;
	
	textureWidth = i.realWidth;
	textureHeight = i.realHeight;
	maxRowsOnScreen = 2 + floor(maxW / (textureWidth + 1));
	maxColsOnScreen = 2 + floor(maxH / (textureHeight + 1));
	
	if (r != UNDEFINED)
	{
		maxRowsOnScreen = MIN(maxRowsOnScreen, r);
	}
	
	if (c != UNDEFINED)
	{
		maxColsOnScreen = MIN(maxColsOnScreen, c);
	}
	
	Image* img = [Image create:i];
	if (self = [super initWithImage:img andCapacity:maxRowsOnScreen * maxColsOnScreen])
	{
		width = maxRowsOnScreen * i.realWidth;
		height = maxColsOnScreen * i.realHeight;
	}
	
	return self;
}

-(void)updateWithCameraPos:(Vector)pos andWorldPos:(Vector)wpos
{
	float px = pos.x;
	float py = pos.y;
	
	x = wpos.x;
	y = wpos.y;
	
	Vector startPos = vect(px - (int)px % textureWidth, py - (int)py % textureHeight);
	Vector currentQuadPos;
	quadsCount = 0;
	for (int i = 0; i < maxRowsOnScreen; i++)
	{
		for (int j = 0; j < maxColsOnScreen; j++)
		{
			currentQuadPos = vectAdd(startPos, vect(j * textureWidth, i * textureHeight));
			if (currentQuadPos.x >= px + cameraWidth)
			{ 
				break;
			}			
			// find intersection rectangle between camera rectangle and every tiled texture rectangle
			Rectangle resScreen = rectInRectIntersection(
				MakeRectangle(px, py, cameraWidth, cameraHeight),
			    MakeRectangle(currentQuadPos.x, currentQuadPos.y, textureWidth, textureHeight));			
			
			Rectangle resTexture = MakeRectangle((px - currentQuadPos.x) + resScreen.x , (py - currentQuadPos.y) + resScreen.y, 
												 resScreen.w, resScreen.h);
			Quad2D texQuad = getTextureCoordinates(image->texture, resTexture);
			Quad3D vertQuad = MakeQuad3D(resScreen.x + x, resScreen.y + y, 0.0, resScreen.w, resScreen.h);
			[self setTextureQuad:&texQuad atVertexQuad:&vertQuad atIndex:quadsCount++];
		}

		if (currentQuadPos.y >= py + cameraHeight)
		{
			break;
		}
		
	}
}

-(void)draw
{
	[super preDraw];
	[super drawNumberOfQuads:quadsCount];
	[super postDraw];
}

@end
