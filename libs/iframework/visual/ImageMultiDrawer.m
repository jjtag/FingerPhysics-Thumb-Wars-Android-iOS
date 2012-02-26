//
//  GLImageEx.m
//  blockit
//
//  Created by Efim Voinov on 19.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageMultiDrawer.h"
#import "Debug.h"

@interface ImageMultiDrawer (Private)
-(void)initIndices;
-(void)freeWithCheck;
@end

@implementation ImageMultiDrawer

-(id)initWithImage:(Image*)i andCapacity:(int)n;
{
	if (!(self = [super init]))
	{
		return nil;
	}
	
	image = [i retain];
	
	numberOfQuadsToDraw	= UNDEFINED;
	totalQuads = n;
	ASSERT(n > 0);
	ASSERT(!(texCoordinates || vertices || indices));
	
	texCoordinates = malloc(sizeof(texCoordinates[0]) * totalQuads);
	vertices = malloc(sizeof(vertices[0]) * totalQuads);
	indices = malloc(sizeof(indices[0]) * totalQuads * 6);
	
	if(!(texCoordinates && vertices && indices)) 
	{
		ASSERT_MSG(FALSE, @"GLImageGrid: not enough memory");
		[self freeWithCheck];
		return nil;
	}
	
	bzero(texCoordinates, sizeof(texCoordinates[0]) * totalQuads);
	bzero(vertices, sizeof(vertices[0]) * totalQuads);	
	bzero(indices, sizeof(indices[0]) * totalQuads);	
	
	[self initIndices];	
	return self;	
}

-(void)freeWithCheck
{
	if(texCoordinates)
	{
		free(texCoordinates);
	}
	if(vertices)
	{
		free(vertices);
	}
	if(indices)
	{
		free(indices);
	}	
}

-(void) dealloc
{
	[self freeWithCheck];
	[image release];
	[super dealloc];
}

// here we set indexes of the arrays in which we hold points to create triangles
-(void) initIndices
{
	for(int i = 0; i < totalQuads; i++) 
	{
		indices[i * 6 + 0] = i * 4 + 0;
		indices[i * 6 + 1] = i * 4 + 1;
		indices[i * 6 + 2] = i * 4 + 2;
		indices[i * 6 + 3] = i * 4 + 3;		
		indices[i * 6 + 4] = i * 4 + 2;
		indices[i * 6 + 5] = i * 4 + 1;
	}
}

-(void)setTextureQuad:(Quad2D*)qt atVertexQuad:(Quad3D*)qv atIndex:(int)n
{	
	if (n >= totalQuads)
	{
		[self resizeCapacity:n + 1];
	}
	
	ASSERT_MSG(n >= 0 && n < totalQuads, @"setTextureQuad: Invalid index");
	
	texCoordinates[n] = *qt;
	vertices[n] = *qv;	
}

-(void)mapTextureQuad:(int)q AtX:(float)dx Y:(float)dy atIndex:(int)n
{	
	if (n >= totalQuads)
	{
		[self resizeCapacity:n + 1];
	}
	
//	ASSERT_MSG(n >= 0 && n < totalQuads, @"setTextureQuad: Invalid index");
//	ASSERT(q >= 0 && q < image->texture->quadsCount);
	
	texCoordinates[n] = image->texture->quads[q];
	vertices[n] = MakeQuad3D(dx + image->texture->quadOffsets[q].x, dy + image->texture->quadOffsets[q].y, 
							 0.0, image->texture->quadRects[q].w, image->texture->quadRects[q].h);	
}

-(void)drawNumberOfQuads:(int)n
{
	glBindTexture(GL_TEXTURE_2D, [image->texture name]);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoordinates);
	glDrawElements(GL_TRIANGLES, n * 6, GL_UNSIGNED_SHORT, indices);		
}

-(void)drawNumberOfQuads:(int)n StartingFrom:(int)s
{
	glBindTexture(GL_TEXTURE_2D, [image->texture name]);
	glVertexPointer(3, GL_FLOAT, 0, &vertices[s]);
	glTexCoordPointer(2, GL_FLOAT, 0, &texCoordinates[s]);
	glDrawElements(GL_TRIANGLES, n * 6, GL_UNSIGNED_SHORT, indices);			
}

-(void)drawAllQuads
{
	return [self drawNumberOfQuads: totalQuads];	
}

-(void)draw
{
	[self preDraw];
	glTranslatef(drawX, drawY, 0);
	if (numberOfQuadsToDraw == UNDEFINED)
	{
		[self drawAllQuads];
	}
	else
	{
		[self drawNumberOfQuads:numberOfQuadsToDraw];
	}
	glTranslatef(-drawX, -drawY, 0);	
	[self postDraw];
}

-(void)resizeCapacity:(int)n
{
	if(n == totalQuads)
	{
		return;
	}
	ASSERT(n > 0);
	
	totalQuads = n;
	
	texCoordinates = realloc(texCoordinates, sizeof(texCoordinates[0]) * totalQuads);
	vertices = realloc(vertices, sizeof(vertices[0]) * totalQuads);
	indices = realloc(indices, sizeof(indices[0]) * totalQuads * 6);
	
	if(!(texCoordinates && vertices && indices)) 
	{
		ASSERT_MSG(FALSE, @"TextureAtlas: not enough memory");
		[self freeWithCheck];
	}
	
	bzero(texCoordinates, sizeof(texCoordinates[0]) * totalQuads);
	bzero(vertices, sizeof(vertices[0]) * totalQuads);	
	bzero(indices, sizeof(indices[0]) * totalQuads);
	
	[self initIndices];	
}

@end
