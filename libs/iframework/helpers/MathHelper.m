//
//  Math.m
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MathHelper.h"
#import "Vector.h"

bool lineInLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
{   
	Vector DP, QA, QB;
	float d, la, lb;
	
	DP.x = x3 - x1 + x4 - x2;
	DP.y = y3 - y1 + y4 - y2;
	QA.x = x2 - x1; 
	QA.y = y2 - y1;
	QB.x = x4 - x3; 
	QB.y = y4 - y3;
	
	d = QA.y * QB.x - QB.y * QA.x;
	la = QB.x * DP.y - QB.y * DP.x;
	lb = QA.x * DP.y - QA.y * DP.x;	
	
	return (abs(la) <= abs(d) && abs(lb) <= abs(d));
};

bool overlaps1Way(Vector* corner, Vector* other) 
{
	Vector axis[2];
	float origin[2];
	axis[0] = vectSub(corner[1], corner[0]); 
	axis[1] = vectSub(corner[3], corner[0]); 
	
	// Make the length of each axis 1/edge length so we know any
	// dot product must be less than 1 to fall within the edge.
	
	for (int a = 0; a < 2; ++a) {
		axis[a] = vectDiv(axis[a], vectLengthsq(axis[a]));;
		origin[a] = vectDot(corner[0], axis[a]);
	}	
	
	for (int a = 0; a < 2; ++a) {
		
		float t = vectDot(other[0], axis[a]);
		
		// Find the extent of box 2 on axis a
		float tMin = t;
		float tMax = t;
		
		for (int c = 1; c < 4; ++c) {
			t = vectDot(other[c], axis[a]);
			
			if (t < tMin) {
				tMin = t;
			} else if (t > tMax) {
				tMax = t;
			}
		}
		
		// We have to subtract off the origin
		
		// See if [tMin, tMax] intersects [0, 1]
		if ((tMin > 1 + origin[a]) || (tMax < origin[a])) {
			// There was no intersection along this dimension;
			// the boxes cannot possibly overlap.
			return false;
		}
	}
	
	// There was no dimension along which there is no intersection.
	// Therefore the boxes overlap.
	return true;
}

bool obbInOBB(Vector tl1, Vector tr1, Vector br1, Vector bl1, Vector tl2, Vector tr2, Vector br2, Vector bl2)
{
	Vector c1[4];
	Vector c2[4];
	
	c1[0] = tl1;
	c1[1] = tr1;
	c1[2] = br1;
	c1[3] = bl1;

	c2[0] = tl2;
	c2[1] = tr2;
	c2[2] = br2;
	c2[3] = bl2;	
	
	return overlaps1Way(c1, c2) && overlaps1Way(c2, c1);	
}

/*
bool lineInRect(float x1, float y1, float x2, float y2, float rx, float ry, float w, float h)
{
	if (x1 > x2) { swapf(&x1, &x2); }
	if (y1 > y2) { swapf(&y1, &y2); }
	
	if (x2 < rx || x1 > rx + w) return FALSE; 
	if (y2 < ry || y1 > ry + h) return FALSE;  
	
	Vector lineVector = vect(x2 - x1, y2 - y1);
	Vector lineAxis = vectPerp(lineVector);	
	lineAxis = vectDiv(lineAxis, vectLengthsq(lineAxis));
	float origin = vectDot(vect(x1, y1), lineAxis);
	
	Vector pts[4] = 
	{
		vect(rx, ry),
		vect(rx + w, ry),
		vect(rx, ry + h),
		vect(rx + w, ry + h)
	};
	
	float t = vectDot(pts[0], lineAxis);
	
	// Find the extent of box on line axis
	float tMin = t;
	float tMax = t;
	
	for (int i = 1; i < 4; i++) 
	{
		t = vectDot(pts[i], lineAxis);
		
		if (t < tMin) 
		{
			tMin = t;
		}
		else if (t > tMax) 
		{
			tMax = t;
		}
	}
	
	// We have to subtract off the origin
	
	// See if [tMin, tMax] intersects [0, 1]
	if ((tMin > 1 + origin) || (tMax < origin)) 
	{
		// There was no intersection along this dimension;
		return FALSE;
	}
	
	return TRUE;
}
*/

#define COHEN_LEFT  1  /* двоичное 0001 */
#define COHEN_RIGHT 2  /* двоичное 0010 */
#define COHEN_BOT   4  /* двоичное 0100 */
#define COHEN_TOP   8  /* двоичное 1000 */

/* вычисление кода точки
 r : указатель на struct rect; p : указатель на struct point */
#define vcode(x_min, y_min, x_max, y_max, p) \
((((p).x < x_min) ? COHEN_LEFT : 0)  +  /* +1 если точка левее прямоугольника */ \
(((p).x > x_max) ? COHEN_RIGHT : 0) +  /* +2 если точка правее прямоугольника */\
(((p).y < y_min) ? COHEN_BOT : 0)   +  /* +4 если точка ниже прямоугольника */  \
(((p).y > y_max) ? COHEN_TOP : 0))     /* +8 если точка выше прямоугольника */

/* если отрезок ab не пересекает прямоугольник r, функция возвращает -1;
 если отрезок ab пересекает прямоугольник r, функция возвращает 0 и отсекает
 те части отрезка, которые находятся вне прямоугольника */

// Cohen-Sutherland algorythm from russian wikipedia
bool lineInRect(float x1, float y1, float x2, float y2, float rx, float ry, float w, float h)
{
	int code_a, code_b, code; /* код конечных точек отрезка */
	Vector a = vect(x1, y1);
	Vector b = vect(x2, y2);
	Vector* c;/* одна из точек */
	
	float x_min = rx;
	float y_min = ry;
	float x_max = rx + w;
	float y_max = ry + h;
	
	code_a = vcode(x_min, y_min, x_max, y_max, a);
	code_b = vcode(x_min, y_min, x_max, y_max, b);
	
	/* пока одна из точек отрезка вне прямоугольника */
	while (code_a || code_b) 
	{
		/* если обе точки с одной стороны прямоугольника, то отрезок не пересекает прямоугольник */
		if (code_a & code_b)
			return FALSE;
		
		/* выбираем точку c с ненулевым кодом */
		if (code_a) 
		{
			code = code_a;
			c = &a;
		} 
		else 
		{
			code = code_b;
			c = &b;
		}
		
		/* если c левее r, то передвигаем c на прямую x = r->x_min
		 если c правее r, то передвигаем c на прямую x = r->x_max */
		if (code & COHEN_LEFT) 
		{
			c->y += (y1 - y2) * (x_min - c->x) / (x1 - x2);
			c->x = x_min;
		} else if (code & COHEN_RIGHT) 
		{
			c->y += (y1 - y2) * (x_max - c->x) / (x1 - x2);
			c->x = x_max;
		}
		/* если c ниже r, то передвигаем c на прямую y = r->y_min
		 если c выше r, то передвигаем c на прямую y = r->y_max */
		if (code & COHEN_BOT) 
		{
			c->x += (x1 - x2) * (y_min - c->y) / (y1 - y2);
			c->y = y_min;
		} 
		else if (code & COHEN_TOP) 
		{
			c->x += (x1 - x2) * (y_max - c->y) / (y1 - y2);
			c->y = y_max;
		}
		
		/* обновляем код */
		if (code == code_a)
		{
			code_a = vcode(x_min, y_min, x_max, y_max, a);
		}
		else
		{
			code_b = vcode(x_min, y_min, x_max, y_max, b);
		}
	}
	
	/* оба кода равны 0, следовательно обе точки в прямоугольнике */
	return TRUE;
}

bool rectInCircle(float left, float right, float top, float bottom, int cx, int cy, int radius)
{
	//int midx = (left + right) / 2;
	//int midy = (top + bottom) / 2;
	
	Vector p[4] =
	{
		vect(left,top),
		vect(right,top),
		vect(left,bottom),
		vect(right,bottom)
	};
	
	Vector axis[6];
	
	Vector center = {cx, cy};
	int i;
	for (i=0; i<4; i++)
	{
		axis[i] = vectNormalize(vectSub(p[i], center));
		p[i] = vectSub(p[i], center);
	}
	
	axis[4] = vect(1,0);
	axis[5] = vect(0,1);
	
	for (i = 0; i < 6; i++)
	{
		float min = 100000000;
		float max = -min;
		for (int j = 0; j < 4; j++)
		{
			float project = vectDot(p[j], axis[i]);
			if (project < min)
				min = project;
			if (project > max)
				max = project;
		}
		
		if (min > radius || max < -radius)
			return FALSE; // found axis of seperation
	}
	
	return TRUE; // no axis of seperation -> intersection
}

int pointOrientation (const Vector p0, const Vector p1, const Vector p2)
{
	Vector a = vectSub(p1, p0);
	Vector b = vectSub(p2, p0);
	float sa = a. x * b.y - b.x * a.y;
	if (sa > 0.0)
	{
		return PT_ORIENTATION_LEFT;
	}
	if (sa < 0.0)
	{
		return PT_ORIENTATION_RIGHT;
	}
	if ((a.x * b.x < 0.0) || (a.y * b.y < 0.0))
	{
		return PT_ORIENTATION_BEHIND;
	}
	if (vectLength(a) < vectLength(b))
	{
		return PT_ORIENTATION_BEYOND;
	}
	if (vectEqual(p0, p2))
	{		
		return PT_ORIENTATION_ORIGIN;		
	}
	if (vectEqual(p1, p2))
	{
		return PT_ORIENTATION_DESTINATION;
	}
	return PT_ORIENTATION_BETWEEN;
}

Rectangle rectInRectIntersection(const Rectangle r1, const Rectangle r2)
{
	Rectangle res = r2;
	res.x = r2.x - r1.x;
	res.y = r2.y - r1.y;
	
	if (res.x < 0)
	{
		res.w += res.x;
		res.x = 0;
	}
	if (res.x + res.w > r1.w)
	{
		res.w = r1.w - res.x;
	}
	if (res.y < 0)
	{
		res.h += res.y;
		res.y = 0;
	}
	if (res.y + res.h > r1.h)
	{
		res.h = r1.h - res.y;
	}	
	
	return res;
}

bool pointInPolygon(float x, float y, int polySides, Vector* poly)
{		
	int i, j = polySides - 1;
	bool oddNodes = FALSE;
	
	for (i = 0; i < polySides; i++) 
	{
		if (poly[i].y < y && poly[j].y >= y || poly[j].y < y && poly[i].y >= y) 
		{
			if (poly[i].x + (y - poly[i].y) / (poly[j].y - poly[i].y) * (poly[j].x - poly[i].x) < x) 
			{
				oddNodes = !oddNodes; 
			}
		}
		
		j = i; 
	}
	
	return oddNodes;
}

float angleTo0_360(float angle)
{
	float res = angle;
	while (ABS(res) > 360.0)
	{
		res -= (res > 0) ? 360.0 : -360.0;
	}		
	
	if (res < 0)
	{
		res += 360.0;		
	}
	
	return res;
}