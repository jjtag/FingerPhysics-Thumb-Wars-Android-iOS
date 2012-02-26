//
//  Framework.m
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

// C Vector implementation
typedef struct Vector
{
	float x, y;
} Vector;

static const Vector vectZero = { 0.0f, 0.0f };
static const Vector vectUndefined = { 0x7FFFFFFF, 0x7FFFFFFF };

static inline Vector vect(const float x, const float y)
{
	Vector v = {x, y};
	return v;
}

static inline bool vectEqual(const Vector v1, const Vector v2)
{
	return (v1.x == v2.x && v1.y == v2.y);
}

static inline Vector vectAdd(const Vector v1, const Vector v2)
{
	return vect(v1.x + v2.x, v1.y + v2.y);
}

static inline Vector vectNeg(const Vector v)
{
	return vect(-v.x, -v.y);
}

static inline Vector vectSub(const Vector v1, const Vector v2)
{
	return vect(v1.x - v2.x, v1.y - v2.y);
}

static inline Vector vectMult(const Vector v, const float s)
{
	return vect(v.x * s, v.y * s);
}

static inline Vector vectDiv(const Vector v, const float s)
{
	return vect(v.x / s, v.y / s);
}

static inline float vectDot(const Vector v1, const Vector v2)
{
	return v1.x*v2.x + v1.y*v2.y;
}

static inline float vectCross(const Vector v1, const Vector v2)
{
	return v1.x*v2.y - v1.y*v2.x;
}

static inline Vector vectPerp(const Vector v)
{
	return vect(-v.y, v.x);
}

static inline Vector vectRperp(const Vector v)
{
	return vect(v.y, -v.x);
}

static inline Vector vectProject(const Vector v1, const Vector v2)
{
	return vectMult(v2, vectDot(v1, v2)/vectDot(v2, v2));
}

static inline Vector vectRotateByVector(const Vector v1, const Vector v2)
{
	return vect(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

static inline Vector vectUnrotateByVector(const Vector v1, const Vector v2)
{
	return vect(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
}

static inline float vectAngle(const Vector v)
{
	return atanf(v.y / v.x);
}

static inline float vectAngleNormalized(const Vector v)
{
	return atan2f(v.y, v.x);
}

#ifdef __cplusplus
extern "C" {
#endif	

float vectLength(const Vector v);
float vectLengthsq(const Vector v); // no sqrt() call
Vector vectNormalize(const Vector v);
Vector vectForAngle(const float a); // convert radians to a normalized vector
float vectToAngle(const Vector v); // convert a vector to radians
float vectDistance(const Vector v1, const Vector v2); // distance between two vectors
Vector vectRotate(const Vector v, double rad);
Vector vectRotateAround(const Vector v, double rad, float cx, float cy);
Vector vectSidePerp(Vector v1, Vector v2);
char *vectStr(const Vector v); // get a string representation of a vector
	
#ifdef __cplusplus
}
#endif		
