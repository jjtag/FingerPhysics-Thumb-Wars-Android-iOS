//
//  GLDrawer.h
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameworkTypes.h"

@class Texture2D;

#ifdef __cplusplus
extern "C" {
#endif	
	
// texture coordinates helper
Quad2D getTextureCoordinates(Texture2D* t, const Rectangle r);

// primitives
void drawRect(float x, float y, float w, float h, const RGBAColor color);
void drawSolidRect(float x, float y, float w, float h, const RGBAColor border, const RGBAColor fill);
void drawSolidRectWOBorder(float x, float y, float w, float h, const RGBAColor fill);
void drawPolygon(const float* vertices, int vertexCount, const RGBAColor color);
void drawSolidPolygon(const float* vertices, int vertexCount, const RGBAColor border, const RGBAColor fill);
void drawSolidPolygonWOBorder(const float* vertices, int vertexCount, const RGBAColor fill);
void drawTexturedPolygon(const float* vertices, const float* texels, int vertexCount, int mode, Texture2D* image);
void drawCircle(float x, float y, float radius, int vertexCount, const RGBAColor color);
void drawSolidCircle(float x, float y, float radius, int vertexCount, const RGBAColor border, const RGBAColor fill);
void drawSolidCircleWOBorder(float x, float y, float radius, int vertexCount, const RGBAColor fill);
void drawTexturedCircle(float x, float y, float radius, const float* texels, int vertexCount, Texture2D* image);
void drawSegment(float x1, float y1, float x2, float y2, const RGBAColor color);
void drawBezierPath(const Vector* pts, int count, int points, const RGBAColor color);
void drawPoint(float x, float y, float size, const RGBAColor color);
void drawTexturedLine(float x1, float y1, float x2, float y2, float size, Texture2D* image);
void drawTexturedPolygonShape(float* vertices, int vertCount, float size, Texture2D* image);
void drawAntialiasedLine(float x1, float y1, float x2, float y2, float size, RGBAColor color);
	
// images
void drawImageColored(Texture2D* image, float x, float y, const RGBAColor color);
void drawImage(Texture2D* image, float x, float y);
void drawImagePart(Texture2D* image, const Rectangle r, float x, float y);
void drawImageQuad(Texture2D* image, int q, float x, float y);
void drawImageTiled(Texture2D* image, int q, float x, float y, float width, float height);

// bezier calculations
Vector calc2PointBezier(const Vector a, const Vector b, float delta);
Vector calcPathBezier(const Vector* p, int count, float delta);

void calcCircle(float x, float y, float radius, int vertexCount, float* glVertices);	
	
// scissor test
void setScissorRectangle(float x, float y, float w, float h);
	
#ifdef __cplusplus
}
#endif	