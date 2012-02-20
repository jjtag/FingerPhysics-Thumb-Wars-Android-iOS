//
//  Arc.m
//  champions
//
//  Created by ikoryakin on 4/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Arc.h"


@implementation Arc

-(void)drawQuad:(int)n
{
	ASSERT(n >= 0 && n < texture->quadsCount);
	float quadWidth = texture->quadRects[n].w;
	float quadHeight = texture->quadRects[n].h;
	
	if (restoreCutTransparency)
	{
		drawX += texture->quadOffsets[n].x;
		drawY += texture->quadOffsets[n].y;
	}
	
	GLfloat vertices[] = {	
		drawX + quadWidth/2, drawY+quadHeight/2,
		drawX, drawY,
		drawX + quadWidth, drawY,
	};	
	
	int vertexCount = sizeof(vertices)/sizeof(GLfloat)/2;
	float* texels = (float*)malloc(sizeof(float)*vertexCount*2);
//	[texture setTexels:texels FromVertices:vertices Count:vertexCount];
//	NSLog(@"---");
	for (int i = 0; i < vertexCount; i++)
	{
		texels[i*2] = (vertices[i*2]-drawX) / (texture.realWidth);
		texels[i*2+1] = (vertices[i*2+1]-drawY) / (texture.realHeight);
//		NSLog(@"%f %f : %f %f", vertices[i*2], vertices[i*2+1], texels[i*2], texels[i*2+1]);
	
	}
	glBindTexture(GL_TEXTURE_2D, [texture name]);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texels);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	free(texels);
}

@end
