//
//  GLTiledImage.h
//  rogatka
//
//  Created by Efim Voinov on 15.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageMultiDrawer.h"
#import "Vector.h"

// class for drawing repeated backs
@interface ScrollingBack : ImageMultiDrawer 
{
	int rows;
	int columns;
	
	int maxRowsOnScreen;
	int maxColsOnScreen;
	
	int textureWidth;
	int textureHeight;
	
	int quadsCount;
@public	
	float cameraWidth;
	float cameraHeight;
}

// use UNDEFINED for Rows or Columns for unlimited tiling (the only option currently supported)
-(id)initWithImage:(Texture2D*)i Rows:(int)r Columns:(int)c maxCameraWidth:(float)maxW Height:(float)maxH;
-(void)updateWithCameraPos:(Vector)pos andWorldPos:(Vector)wpos;

@end
