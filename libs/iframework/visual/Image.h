//
//  Image.h
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLDrawer.h"
#import "BaseElement.h"
#import "../support/Texture2D.h"
#import "FrameworkTypes.h"

// image actions
extern const NSString* ACTION_SET_DRAWQUAD;

// opengles texture container with ability to calculate and draw quads
@interface Image : BaseElement 
{
@public	
	Texture2D* texture;

@protected
	bool restoreCutTransparency;
	int quadToDraw;	
}

@property (readonly) Texture2D* texture;

// helpers
+(Image*)create:(Texture2D*)t;
+(Image*)createWithResID:(int)r;
+(Image*)createWithResID:(int)r Quad:(int)q;

-(id)initWithTexture:(Texture2D*)t;

-(void)setDrawFullImage;
-(void)setDrawQuad:(int)n;
// when drawing image, restore it's initial size before cutting transparency
-(void)doRestoreCutTransparency;
-(void)draw;
-(void)drawQuad:(int)n;

@end
