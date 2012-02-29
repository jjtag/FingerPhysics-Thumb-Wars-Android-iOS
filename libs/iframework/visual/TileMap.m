//
//  Background.m
//  buck
//
//  Created by Mac on 24.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TileMap.h"
#import "Debug.h"
#import "Framework.h"

@implementation TileEntry
@end

@implementation TileMap

-(id)initWithRows:(int)r Columns:(int)c
{
	if (self = [super init])
	{
		rows = r;
		columns = c;				
		ASSERT(rows > 0 && columns > 0);

		cameraViewWidth = SCREEN_WIDTH;
		cameraViewHeight = SCREEN_HEIGHT;
		
		parallaxRatio = 1.0;
		
		drawers = [[DynamicArray alloc] init];
		tiles = [[DynamicArray alloc] init];
		
		matrix = (int**)malloc(sizeof(int*) * columns);
		for (int i = 0; i < columns; i++)
		{
			matrix[i] = (int*)malloc(sizeof(int) * rows);
			for (int k = 0; k < rows; k++)
			{
				matrix[i][k] = UNDEFINED;
			}
		}
		
		repeatedVertically = REPEAT_NONE;
		repeatedHorizontally = REPEAT_NONE;
		horizontalRandom = FALSE;
		verticalRandom = FALSE;
		restoreTileTransparency = TRUE;
		
		randomSeed = RND_RANGE(1000, 2000);
	}
		
	return self;
}

-(void)addTile:(Texture2D*)t Quad:(int)q withID:(int)ti
{
	ASSERT(ti >= 0);
		
	if (q == UNDEFINED)
	{
		tileWidth = t->_realWidth;
		tileHeight = t->_realHeight;
	}
	else
	{
		tileWidth = t->quadRects[q].w;
		tileHeight = t->quadRects[q].h;
	}

	[self updateVars];	
	
	int drawerID = UNDEFINED;
	for (int i = 0; i < [drawers count]; i++)
	{
		ImageMultiDrawer* d	= [drawers objectAtIndex:i];
		if (d->image->texture == t)
		{
			drawerID = i;
		}
		
		if (d->image->texture->_realWidth != tileWidth || d->image->texture->_realHeight != tileHeight)
		{
			ASSERT(@"Various size tiles in the tile map");
		}
	}
	
	if (drawerID == UNDEFINED)
	{
		Image* img = [Image create:t];	
		if (restoreTileTransparency)
		{
			[img doRestoreCutTransparency];
		}
		ImageMultiDrawer* d = [[ImageMultiDrawer allocAndAutorelease] initWithImage:img andCapacity:maxRowsOnScreen * maxColsOnScreen];
		drawerID = [drawers addObject:d];
	}
	
	TileEntry* e = [TileEntry create];
	e->drawerIndex = drawerID;
	e->quad = q;
	[tiles setObject:e At:ti];
}

-(void)updateVars
{
	maxColsOnScreen = 2 + floor(cameraViewWidth / (tileWidth + 1));
	maxRowsOnScreen = 2 + floor(cameraViewHeight / (tileHeight + 1));
	
	if (repeatedVertically == REPEAT_NONE)
	{
		maxRowsOnScreen = MIN(maxRowsOnScreen, rows);
	}

	if (repeatedHorizontally == REPEAT_NONE)
	{
		maxColsOnScreen = MIN(maxColsOnScreen, columns);
	}		
	
	width = tileMapWidth = columns * tileWidth;
	height = tileMapHeight = rows * tileHeight;
}

-(void)fillStartAtRow:(int)r Column:(int)c Rows:(int)rs Columns:(int)cs withTile:(int)ti
{
	ASSERT(rectInRect(0, 0, columns, rows, c, r, c + cs, r + rs));
	
	for (int i = c; i < c + cs; i++)
	{
		for (int k = r; k < r + rs; k++)
		{
			matrix[i][k] = ti;
		}
	}
}

-(void)setParallaxRatio:(float)r
{
	ASSERT(r >= 0);
	
	parallaxRatio = r;
}

-(void)setRepeatHorizontally:(int)r
{
	ASSERT(r == REPEAT_NONE || r == REPEAT_ALL || r == REPEAT_EDGES);
	repeatedHorizontally = r;
	[self updateVars];
}

-(void)setRepeatVertically:(int)r
{
	ASSERT(r == REPEAT_NONE || r == REPEAT_ALL || r == REPEAT_EDGES);
	repeatedVertically = r;	
	[self updateVars];	
}

-(void)updateWithCameraPos:(Vector)pos
{
	ASSERT_MSG(anchor == TOP | LEFT, @"tilemap doesn't support anchoring");
	
	// calculate source coordinates based on parallax ratio
	float mx = round(pos.x / parallaxRatio);
	float my = round(pos.y / parallaxRatio);
	
	float tileMapStartX = x;
	float tileMapStartY = y;

	if (repeatedVertically != REPEAT_NONE)
	{		
		float ys = tileMapStartY - my;
		int a = (int)ys % tileMapHeight;
		if (ys < 0)
		{
			tileMapStartY = a + my;
		}
		else
		{
			tileMapStartY = a - tileMapHeight + my;
		}
	}	
	
	if (repeatedHorizontally != REPEAT_NONE)
	{		
		float xs = tileMapStartX - mx;
		int a = (int)xs % tileMapWidth;
		if (xs < 0)
		{
			tileMapStartX = a + mx;
		}
		else
		{
			tileMapStartX = a - tileMapWidth + mx;
		}
	}
	
	// tile map is not in camera view
	if (!rectInRect(mx, my, mx + cameraViewWidth, my + cameraViewHeight, tileMapStartX, tileMapStartY, tileMapStartX + tileMapWidth, tileMapStartY + tileMapHeight))
	{
		return;
	}
	
	Rectangle cameraInTilemap = rectInRectIntersection(MakeRectangle(tileMapStartX, tileMapStartY, tileMapWidth, tileMapHeight),
													   MakeRectangle(mx, my, cameraViewWidth, cameraViewHeight));
	
	Vector checkPoint = vect(MAX(0, cameraInTilemap.x), MAX(0, cameraInTilemap.y));			
	Vector startPos = vect((int)checkPoint.x / tileWidth, (int)checkPoint.y / tileHeight);
	float highestQuadY = tileMapStartY + startPos.y * tileHeight;
	Vector currentQuadPos = vect(tileMapStartX + startPos.x * tileWidth, highestQuadY);
	for (ImageMultiDrawer* d in drawers)
	{
		d->numberOfQuadsToDraw = 0;
	}
	
	int maxColumn = startPos.x + maxColsOnScreen - 1; 
	int maxRow = startPos.y + maxRowsOnScreen - 1;

	if (repeatedVertically == REPEAT_NONE)
	{
		maxRow = MIN(rows - 1, maxRow);
	}
	if (repeatedHorizontally == REPEAT_NONE)
	{
		maxColumn = MIN(columns - 1, maxColumn);
	}
	
	for (int i = startPos.x; i <= maxColumn; i++)
	{
		currentQuadPos.y = highestQuadY;

		for (int j = startPos.y; j <= maxRow; j++)
		{
			if (currentQuadPos.y >= my + cameraViewHeight)
			{ 
				break;
			}			
			// find intersection rectangle between camera rectangle and every tiled texture rectangle
			Rectangle resScreen = rectInRectIntersection(
														 MakeRectangle(mx, my, cameraViewWidth, cameraViewHeight),
														 MakeRectangle(currentQuadPos.x, currentQuadPos.y, tileWidth, tileHeight));			
			
			Rectangle resTexture = MakeRectangle((mx - currentQuadPos.x) + resScreen.x , (my - currentQuadPos.y) + resScreen.y, 
												 resScreen.w, resScreen.h);

			int ri = i;
			int rj = j;
			
			if (repeatedVertically == REPEAT_EDGES)
			{
				if (currentQuadPos.y < y)
				{
					rj = 0;
				}
				else if (currentQuadPos.y >= y + tileMapHeight)
				{
					rj = rows - 1;
				}
			}

			if (repeatedHorizontally == REPEAT_EDGES)
			{
				if (currentQuadPos.x < x)
				{
					ri = 0;
				}
				else if (currentQuadPos.x >= x + tileMapWidth)
				{
					ri = columns - 1;
				}
			}			
			
			if (horizontalRandom)
			{
				float v = sin(currentQuadPos.x) * randomSeed;
				ri = ABS((int)v % columns);
			}

			if (verticalRandom)
			{
				float v = sin(currentQuadPos.y) * randomSeed;
				rj = ABS((int)v % rows);
			}			
			
			if (ri >= columns)
			{
				ri = ri % columns;
			}
			
			if (rj >= rows)
			{
				rj = rj % rows;
			}
			
			int tile = matrix[ri][rj];
			if (tile >= 0)
			{
				TileEntry* e = [tiles objectAtIndex:tile];
				ImageMultiDrawer* d = [drawers objectAtIndex:e->drawerIndex];
				Texture2D* t = d->image->texture;
				Quad2D texQuad;
				if (e->quad != UNDEFINED)
				{
					resTexture.x += t->quadRects[e->quad].x;
					resTexture.y += t->quadRects[e->quad].y;	
				}

				texQuad = getTextureCoordinates(d->image->texture, resTexture);				
				
				Quad3D vertQuad = MakeQuad3D(pos.x + resScreen.x, pos.y + resScreen.y, 0.0, resScreen.w, resScreen.h);
				
				[d setTextureQuad:&texQuad atVertexQuad:&vertQuad atIndex:d->numberOfQuadsToDraw++];
			}
			currentQuadPos.y += tileHeight;
		}

		currentQuadPos.x += tileWidth;		
		
		if (currentQuadPos.x >= mx + cameraViewWidth)
		{
			break;
		}
		
	}
}

-(void)draw
{
	for (ImageMultiDrawer* d in drawers)
	{
		[d draw];
	}	
}

-(void)dealloc
{
	for (int i = 0; i < columns; i++)
	{
		free(matrix[i]);
	}
	
	free(matrix);
	
	[drawers release];
	[tiles release];
	[super dealloc];
}

@end
