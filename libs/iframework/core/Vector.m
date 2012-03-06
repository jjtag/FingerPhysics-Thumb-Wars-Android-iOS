//
//  Framework.m
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
 
#include "Vector.h"
#include "stdio.h"

float vectLength(const Vector v)
{
	return sqrtf( vectDot(v, v) );
}

float vectLengthsq(const Vector v)
{
	return vectDot(v, v);
}

Vector vectNormalize(const Vector v)
{
	return vectMult( v, 1.0f/vectLength(v) );
}

Vector vectForAngle(const float a)
{
	return vect(cos(a), sin(a));
}

float vectToAngle(const Vector v)
{
	return atan2(v.x, v.y);
}

float vectDistance(const Vector v1, const Vector v2)
{
	Vector tmp = vectSub(v1, v2);
	return vectLength(tmp);
}

Vector vectRotate(const Vector v, double rad)
{
	float cosA = cos(rad); //TODO: think about caching values
	float sinA = sin(rad);
	
	float nx = v.x * cosA - v.y * sinA;
	float ny = v.x * sinA + v.y * cosA;
	return vect(nx, ny);
}

Vector vectRotateAround(const Vector v, double rad, float cx, float cy)
{
	Vector res = v;
	res.x -= cx;
	res.y -= cy;
	
	res = vectRotate(res, rad);
	
	res.x += cx;
	res.y += cy;
	
	return res;
}

Vector vectSidePerp(Vector v1, Vector v2)
{
	Vector vp = vectRperp(vectSub(v2, v1));
	return vectNormalize(vp);
}

char* vectStr(const Vector v)
{
	static char str[256];
	sprintf(str, "(% .3f, % .3f)", v.x, v.y);
	return str;
}