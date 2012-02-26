//
//  Math.h
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FrameworkTypes.h"

// math macros and helpers

#define BIT(n) (1 << (n))

// returns random number in [0...n] inclusevly
#define RND(N) (random() % ((N) + 1))
// returns random number in [s...f] inclusevly
#define RND_RANGE(S,F) ((S) + RND((F)-(S)))
// -1..1
#define RND_MINUS1_1 ((random() / (float)0x3fffffff )-1.0f)
//  0..1
#define RND_0_1 ((random() / (float)0x7fffffff ))

#define DEGREES_TO_RADIANS(D) (((D) * M_PI) / 180.0)
#define RADIANS_TO_DEGREES(R) (((R) * 180.0) / M_PI)

// fit value V to [MINV, MAXV]
#define FIT_TO_BOUNDARIES(V,MINV,MAXV) MAX(MIN((V),(MAXV)),(MINV))

static inline float hypotinuse(float dx, float dy)
{
	return sqrtf(dx * dx + dy * dy);
}

// swaps two floats
static inline void swapf(float* a, float* b)
{
	float t = *a;
	*a = *b;
	*b = t;
}

// swaps two ints
static inline void swap(int* a, int* b)
{
	int t = *a;
	*a = *b;
	*b = t;
}

static inline bool sameSign(float a, float b)
{
	return ((a >= 0 && b >= 0) || (a < 0 && b < 0));
}

// point - rectangle collision
static inline bool pointInRect(float x, float y, float checkX, float checkY, float checkWidth, float checkHeight)
{
	return (x >= checkX && x < checkX + checkWidth && y >= checkY && y < checkY + checkHeight);
}

// retangle - rectangle collision
static inline bool rectInRect(float x1l, float y1t, float x1r, float y1b, float x2l, float y2t, float x2r, float y2b)
{
    return !(x1l > x2r ||  x1r < x2l ||  y1t > y2b ||  y1b < y2t);
}

// checks and swaps rectangle points if needed
static inline bool rectInRectWCheck(float x1l, float y1t, float x1r, float y1b, float x2l, float y2t, float x2r, float y2b)
{
	if (x1l > x1r) { swapf(&x1l, &x1r); }
	if (y1t > y1b) { swapf(&y1t, &y1b); }
	if (x2l > x2r) { swapf(&x2l, &x2r); }
	if (y2t > y2b) { swapf(&y2t, &y2b); }
    
	return !(x1l > x2r ||  x1r < x2l ||  y1t > y2b ||  y1b < y2t);
}

// get intersection rectangle, it's 0,0 is in the r1 top left corner
Rectangle rectInRectIntersection(const Rectangle r1, const Rectangle r2);

// rotated rectangle in rotated rectangle
bool obbInOBB(Vector tl1, Vector tr1, Vector br1, Vector bl1, Vector tl2, Vector tr2, Vector br2, Vector bl2);

// line - line intersection
bool lineInLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4);

// line - rect
bool lineInRect(float x1, float y1, float x2, float y2, float rx, float ry, float w, float h);

// rect - circle
bool rectInCircle(float left, float right, float top, float bottom, int cx, int cy, int radius);

bool pointInPolygon(float x, float y, int polySides, Vector* poly);

enum {PT_ORIENTATION_LEFT,  PT_ORIENTATION_RIGHT,  PT_ORIENTATION_BEYOND,  PT_ORIENTATION_BEHIND, 
PT_ORIENTATION_BETWEEN, PT_ORIENTATION_ORIGIN, PT_ORIENTATION_DESTINATION};

// orientation of point p2 to the p0-p1 line
int pointOrientation (const Vector p0, const Vector pl, const Vector p2);

// this is a approximate yet fast inverse square-root.
static inline float invSqrt(float x)
{
	union
	{
		float x;
		int i;
	} convert;
	
	convert.x = x;
	float xhalf = 0.5f * x;
	convert.i = 0x5f3759df - (convert.i >> 1);
	x = convert.x;
	x = x * (1.5f - xhalf * x * x);
	return x;
}

// convert any angle to [0..360] form
float angleTo0_360(float angle);