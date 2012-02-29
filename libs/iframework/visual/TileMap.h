//
//  Background.h
//  buck
//
//  Created by Mac on 24.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseElement.h"
#import "ImageMultiDrawer.h"

@interface TileEntry : NSObject
{
@public
	int drawerIndex;
	int quad;
}

@end

enum {REPEAT_NONE, REPEAT_ALL, REPEAT_EDGES};

// Fixed - tile size tile map with parallax support
@interface TileMap : BaseElement
{
@public
	int** matrix;
	
	int rows;
	int columns;	

@protected
	DynamicArray* drawers;
	DynamicArray* tiles;
	
	int cameraViewWidth;
	int cameraViewHeight;
	
	int tileMapWidth;
	int tileMapHeight;
	
	int maxRowsOnScreen;
	int maxColsOnScreen;
		
	int randomSeed;

	// should the tile map be repeated
	int repeatedVertically;
	int repeatedHorizontally;		
	
@public	
	// how many times the tilemap is moving slowly than a camera
	float parallaxRatio;
	
	int tileWidth;
	int tileHeight;
		
	// places tiles randomly
	bool horizontalRandom;
	bool verticalRandom;
	
	// restore cut transparency in tiles
	bool restoreTileTransparency;
}

-(id)initWithRows:(int)rows Columns:(int)columns;
-(void)addTile:(Texture2D*)t Quad:(int)q withID:(int)i;
-(void)fillStartAtRow:(int)r Column:(int)c Rows:(int)rs Columns:(int)cs withTile:(int)i;
-(void)setParallaxRatio:(float)r;
-(void)setRepeatHorizontally:(int)r;
-(void)setRepeatVertically:(int)r;
-(void)updateWithCameraPos:(Vector)pos;

-(void)updateVars;

@end
