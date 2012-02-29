//
//  GLImageEx.h
//  blockit
//
//  Created by Efim Voinov on 19.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Image.h"
#import "GLDrawer.h"
#import "BaseElement.h"

// drawer with the ability to draw many parts of texture (quads) using the single opengl drawing routine
@interface ImageMultiDrawer : BaseElement
{
@public
	Image* image;
	
	int totalQuads;
	Quad2D* texCoordinates;
	Quad3D* vertices;
	GLushort* indices;
	
	int numberOfQuadsToDraw;
}

-(id)initWithImage:(Image*)i andCapacity:(int)n;

// use this to map pre-created quads in source image
-(void)mapTextureQuad:(int)q AtX:(float)x Y:(float)y atIndex:(int)n;
// use this to create new quads and map them on the fly
-(void)setTextureQuad:(Quad2D*)qt atVertexQuad:(Quad3D*)qv atIndex:(int)n;

-(void)drawNumberOfQuads:(int)n;
-(void)drawNumberOfQuads:(int)n StartingFrom:(int)s;
-(void)drawAllQuads;
-(void)draw;
-(void)resizeCapacity:(int)n;

-(void)initIndices;
-(void)freeWithCheck;

@end
