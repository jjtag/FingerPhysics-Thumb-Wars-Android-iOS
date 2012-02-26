//
//  TiledImage.m
//  buck
//
//  Created by Mac on 30.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TiledImage.h"

@implementation TiledImage

-(id)initWithTexture:(Texture2D*)t
{
	if (self = [super initWithTexture:t])
	{
		for (int i = 0; i < 9; i++)
		{
			tiles[i] = UNDEFINED;
		}
	}
	
	return self;
}

-(void)draw
{
	[self preDraw];

	//TODO: implement all tiling types

	float leftQuadWidth = texture->quadRects[tiles[TILE_CENTER_LEFT]].w;	
	float centerQuadWidth = texture->quadRects[tiles[TILE_CENTER_CENTER]].w;	
	float rightQuadWidth = texture->quadRects[tiles[TILE_CENTER_RIGHT]].w;	
	
	float tileWidth = width - (leftQuadWidth + rightQuadWidth);
	if (tileWidth >= 0)
	{
		drawImageQuad(texture, tiles[TILE_CENTER_LEFT], drawX, drawY);
		drawImageTiled(texture, tiles[TILE_CENTER_CENTER], drawX + leftQuadWidth, drawY, tileWidth, height);
		drawImageQuad(texture, tiles[TILE_CENTER_RIGHT], drawX + leftQuadWidth + tileWidth, drawY);
	}
	else
	{		
		Rectangle p1 = texture->quadRects[tiles[TILE_CENTER_LEFT]];
		Rectangle p2 = texture->quadRects[tiles[TILE_CENTER_RIGHT]];
		p1.w = MIN(p1.w, width / 2.0);
		p2.w = MIN(p2.w, width - p1.w);
		p2.x += (texture->quadRects[tiles[TILE_CENTER_RIGHT]].w - p2.w);
		drawImagePart(texture, p1, drawX, drawY);
		drawImagePart(texture, p2, drawX + p1.w, drawY);		
	}
		
	[self postDraw];	
}

@end
