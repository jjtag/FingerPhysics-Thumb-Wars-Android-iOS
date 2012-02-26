//
//  TiledImage.h
//  buck
//
//  Created by Mac on 30.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Image.h"

enum 
{
	  TILE_TOP_LEFT, TILE_TOP_CENTER, TILE_TOP_RIGHT, 
	  TILE_CENTER_LEFT, TILE_CENTER_CENTER, TILE_CENTER_RIGHT,
	  TILE_BOTTOM_LEFT, TILE_BOTTOM_CENTER, TILE_BOTTOM_RIGHT
};

// image that is drawn using tiles
// only horizontal tiling is supported now
@interface TiledImage : Image
{
@public
	int tiles[9];
}

@end
