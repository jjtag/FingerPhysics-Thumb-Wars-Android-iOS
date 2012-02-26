//
//  GLDrawer.m
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLDrawer.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "../support/Texture2D.h"
#import "Debug.h"
#import "ApplicationSettings.h"
#import "Application.h"

void drawImageColored(Texture2D* image, float x, float y, const RGBAColor color)
{	
	glColor4f(color.r, color.g, color.b, color.a);		
	drawAtPoint(image, vect(x, y));
}

void drawImage(Texture2D* image, float x, float y)
{
	drawAtPoint(image, vect(x, y));
}

void drawImagePart(Texture2D* image, const Rectangle r, float x, float y)
{
	drawRectAtPoint(image, r, vect(x,y));
}

void drawImageQuad(Texture2D* image, int q, float x, float y)
{
	if (q == UNDEFINED)
	{
		drawImage(image, x, y);
	}
	else
	{
		drawQuadAtPoint(image, q, vect(x,y));
	}
}

void drawImageTiled(Texture2D* image, int q, float x, float y, float width, float height)
{				        	
	float qx = 0;
	float qy = 0;
	float qw;
	float qh;
	
	if (q == UNDEFINED)
	{
		qw = image->_realWidth;
		qh = image->_realHeight;		
	}
	else
	{
		qx = image->quadRects[q].x;
		qy = image->quadRects[q].y;
		qw = image->quadRects[q].w;
		qh = image->quadRects[q].h;		
	}
	
	if (width == qw && height == qh)
	{
		drawImageQuad(image, q, x, y);
	}
	else
	{
		int horRep = ceil(width / qw);
		int verRep = ceil(height / qh);
		
		int xoff = (int)width % (int)qw;
		int yoff = (int)height % (int)qh;	        	
		int lastPartWidth = (xoff == 0) ? qw : xoff;
		int lastPartHeight = (yoff == 0) ? qh : yoff; 
		
		int dx = x;
		int dy = y;
		
		for (int yc = verRep - 1; yc >= 0; yc--)
		{
			dx = x;
			for (int xc = horRep - 1; xc >= 0; xc--)
			{
				if (xc == 0 || yc == 0)
				{
					Rectangle rect = MakeRectangle(qx, qy, 
													   (xc == 0) ? lastPartWidth : qw, 
													   (yc == 0) ? lastPartHeight : qh);
					drawImagePart(image, rect, dx, dy);
				}
				else
				{
					drawImageQuad(image, q, dx, dy);
				}
				dx += qw;
			}
			dy += qh;	        		
		}	        	   
	}     	 
}

void drawRect(float x, float y, float w, float h, const RGBAColor color)
{
	const float verts[8] = { x, y, x + w, y, x + w, y + h, x, y + h };
	drawPolygon(verts, 4, color);
}

void drawSolidRect(float x, float y, float w, float h, const RGBAColor border, const RGBAColor fill)
{
	const float verts[8] = { x, y, x + w, y, x + w, y + h, x, y + h };
	drawSolidPolygon(verts, 4, border, fill);	
}

void drawSolidRectWOBorder(float x, float y, float w, float h, const RGBAColor fill)
{
	const float vertices[8] = { x, y, x + w, y, x + w, y + h, x, y + h };	

	glColor4f(fill.r, fill.g, fill.b, fill.a);
	glVertexPointer(2, GL_FLOAT, 0, vertices);	
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

void drawPolygon(const float* vertices, int vertexCount, const RGBAColor color)
{
	glColor4f(color.r, color.g, color.b, color.a);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void drawSolidPolygon(const float* vertices, int vertexCount, const RGBAColor border, const RGBAColor fill)
{
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	
	glColor4f(fill.r, fill.g, fill.b, fill.a);
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
	glColor4f(border.r, border.g, border.b, border.a);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);		
}

void drawSolidPolygonWOBorder(const float* vertices, int vertexCount, const RGBAColor fill)
{
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	
	glColor4f(fill.r, fill.g, fill.b, fill.a);
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
}

void drawTexturedPolygon(const float* vertices, const float* texels, int vertexCount, int mode, Texture2D* image)
{
	[image drawPolygon:vertices Texels:texels Count:vertexCount Mode:mode];
}

void drawTexturedLine(float x1, float y1, float x2, float y2, float size, Texture2D* image)
{
	// вычислить прямоугольник огибающий линию
//	NSLog(@"\t\t%f, %f | %f, %f", x1, y1, x2, y2);
	Vector v1 = vect(x1,y1);
	Vector v2 = vect(x2,y2);
	Vector vline = vectSub(v2, v1);
	Vector vlp1 = vectPerp(vline);
	vlp1 = vectMult(vectNormalize(vlp1), size);
	Vector vlpn1 = vectNeg(vlp1); 
	
	Vector vlp2 = vectAdd(vlp1, vline);
	Vector vlpn2 = vectAdd(vectNeg(vlp1), vline);
	vlp1 = vectAdd(vlp1, v1);
	vlpn1 = vectAdd(vlpn1, v1);
	vlp2 = vectAdd(vlp2, v1);
	vlpn2 = vectAdd(vlpn2, v1);
//	NSLog(@"[%f,%f] [%f,%f]", vlp1.x, vlp1.y, vlp2.x, vlp2.y);
//	NSLog(@"[%f,%f] [%f,%f]", vlpn1.x, vlpn1.y, vlpn2.x, vlpn2.y);
	
	// вычислить текстурные координаты прямоугольника
	Rectangle rect = MakeRectangle(0, 0, (vectLength(vline)), (size*2));
	Quad2D txls = getTextureCoordinates(image, rect);

	float verts[] = 
	
	{
		vlp1.x, vlp1.y,
		vlp2.x, vlp2.y,
		vlpn1.x, vlpn1.y,
		vlpn2.x, vlpn2.y,
	};

	float texels[] = 
	{
		txls.blX, txls.blY,
		txls.brX, txls.brY,
		txls.tlX, txls.tlY,
		txls.trX, txls.trY,
	};		
	
	
	// отрисовать с помощью drawTexturedPolygon	
	drawTexturedPolygon(verts, texels, 4, GL_TRIANGLE_STRIP, image);
}

void drawTexturedPolygonShape(float* vertices, int vertCount, float size, Texture2D* image)
{
	for(int i = 0; i<=(vertCount*2)-4; i+=2)
	{
		drawTexturedLine(vertices[i], vertices[i+1], vertices[i+2], vertices[i+3], size, image);
	}
	drawTexturedLine( vertices[(vertCount*2)-2], vertices[(vertCount*2)-1], vertices[0], vertices[1], size, image);
}

void drawAntialiasedLine(float x1, float y1, float x2, float y2, float size, RGBAColor color)
{
	Vector v1 = vect(x1,y1);
	Vector v2 = vect(x2,y2);
	Vector vline = vectSub(v2, v1);
	Vector vlp1 = vectPerp(vline);
	Vector nvlp1 = vectNormalize(vlp1);
	vlp1 = vectMult(nvlp1, size);
	Vector vlpn1 = vectNeg(vlp1); 
	
	Vector vlp2 = vectAdd(vlp1, vline);
	Vector vlpn2 = vectAdd(vectNeg(vlp1), vline);
	vlp1 = vectAdd(vlp1, v1);
	vlpn1 = vectAdd(vlpn1, v1);
	vlp2 = vectAdd(vlp2, v1);
	vlpn2 = vectAdd(vlpn2, v1);
	
	
	Vector vln1 = vectSub(vlp1, nvlp1);
	Vector vln2 = vectSub(vlp2, nvlp1);
	Vector vlm1 = vectAdd(vlpn1, nvlp1);
	Vector vlm2 = vectAdd(vlpn2, nvlp1);
	
	float verts[] = 	
	{
		vlp1.x, vlp1.y,
		vlp2.x, vlp2.y,
		vln1.x, vln1.y,
		vln2.x, vln2.y,
		vlm1.x, vlm1.y,
		vlm2.x, vlm2.y,
		vlpn1.x, vlpn1.y,
		vlpn2.x, vlpn2.y,
	};
	
	RGBAColor colors[] = 
	{
		transparentRGBA, 
		transparentRGBA,		
		color,
		color,
		color,
		color,
		transparentRGBA, 
		transparentRGBA,		
	};
	
	glColorPointer(4, GL_FLOAT, 0, colors);
	glDisableClientState(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, verts);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 8);
	glEnableClientState(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);	
}

void calcCircle(float x, float y, float radius, int vertexCount, float* glVertices)
{
	const float k_increment = 2.0f * M_PI / vertexCount;
	float theta = 0.0f;
	
	for (int i = 0; i < vertexCount; ++i)
	{
		glVertices[i*2] = x + radius * cosf(theta);
		glVertices[i*2+1] = y + radius * sinf(theta);
		theta += k_increment;
	}	
}

void drawCircle(float x, float y, float radius, int vertexCount, const RGBAColor color)
{
	float glVertices[vertexCount * 2];	
	calcCircle(x, y, radius, vertexCount, (float*)&glVertices);
	
	glColor4f(color.r, color.g, color.b, color.a);
	glVertexPointer(2, GL_FLOAT, 0, glVertices);	
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void drawSolidCircle(float x, float y, float radius, int vertexCount, const RGBAColor border, const RGBAColor fill)
{
	float	glVertices[vertexCount * 2];	
	calcCircle(x, y, radius, vertexCount, (float*)&glVertices);
	
	glColor4f(fill.r, fill.g, fill.b, fill.a);
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
	glColor4f(border.r, border.g, border.b, border.a);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);	
}

void drawSolidCircleWOBorder(float x, float y, float radius, int vertexCount, const RGBAColor fill)
{
	float glVertices[vertexCount * 2];
	calcCircle(x, y, radius, vertexCount, (float*)&glVertices);
	
	glColor4f(fill.r, fill.g, fill.b, fill.a);
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
}

void drawTexturedCircle(float x, float y, float radius, const float* texels, int vertexCount, Texture2D* image)
{
	float glVertices[vertexCount * 2];	
	calcCircle(x, y, radius, vertexCount, (float*)&glVertices);
	
	[image drawPolygon:glVertices Texels:texels Count:vertexCount Mode:GL_TRIANGLE_FAN];	
}

void drawSegment(float x1, float y1, float x2, float y2, const RGBAColor color)
{
	glColor4f(color.r, color.g, color.b, color.a);
	GLfloat	glVertices[] = {
		x1, y1, x2, y2
	};
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_LINES, 0, 2);
}

Vector calc2PointBezier(const Vector a, const Vector b, float delta)  
{
	float d1;  
	Vector res;
	d1 = 1.0 - delta;  
	res.x = a.x * d1 + b.x * delta;  
	res.y = a.y * d1 + b.y * delta;  
	
	return res;
}

Vector calcPathBezier(const Vector* p, int count, float delta)
{  
	Vector v[count - 1];
	int i;  
	Vector res;

	if (count > 2)
	{
		for (i = 0; i < count - 1; i++)
		{
		   v[i] = calc2PointBezier(p[i], p[i + 1], delta);  
		}
		res = calcPathBezier(v, count - 1, delta);  
	} 
	else if (count == 2)
	{
		res = calc2PointBezier(p[0], p[1], delta);  
	}
	 
	return res;
}  

void drawBezierPath(const Vector* pts, int count, int points, const RGBAColor color)
{
	Vector p;
	int numVertices = (count - 1) * points;
	GLfloat	glVertices[numVertices * 2];
	
	float step = 1.0 / numVertices;
	float a = 0.0;
	int c = 0;
	while (TRUE)
	{
		if (a > 1.0) a = 1.0;
		
		p = calcPathBezier(pts, count, a);
		glVertices[c++] = p.x;
		glVertices[c++] = p.y;
		if (a == 1.0)
		{
			break;
		}
			
		a += step;
	}
	
	glColor4f(color.r, color.g, color.b, color.a);
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_LINE_STRIP, 0, c >> 1);	
}

void drawPoint(float x, float y, float size, const RGBAColor color)
{
	glColor4f(color.r, color.g, color.b, color.a);
	glPointSize(size);
	GLfloat	glVertices[] = {x, y};
	
	glVertexPointer(2, GL_FLOAT, 0, glVertices);
	glDrawArrays(GL_POINTS, 0, 1);
	glPointSize(1.0f);
}

void setScissorRectangle(float x, float y, float w, float h)
{
	int or = [[Application sharedAppSettings] getInt:APP_SETTING_ORIENTATION];
	
	if (or == ORIENTATION_PORTRAIT)
	{
		glScissor(x, SCREEN_HEIGHT - (y + h), w, h);
	}
	else if (or == ORIENTATION_LANDSCAPE_LEFT)
	{
		glScissor(y, x, h, w);		
	}
	else
	{
		ASSERT(or == ORIENTATION_LANDSCAPE_RIGHT);
		glScissor(SCREEN_HEIGHT - (y + h), SCREEN_WIDTH - (x + w), h, w);	
	}	
}

Quad2D getTextureCoordinates(Texture2D* t, const Rectangle r)
{
	return MakeQuad2D(t->_invWidth * r.x, t->_invHeight * r.y, t->_invWidth * r.w, t->_invHeight * r.h);	
}
