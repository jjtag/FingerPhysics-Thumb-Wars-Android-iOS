//
//  FrameworkTypes.h
//  blockit
//
//  Created by Efim Voinov on 20.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "Vector.h"

#define UNDEFINED -1

#define FLOAT_PRECISION 0.000001

typedef float TimeType;

// string format helper
#define FORMAT_STRING(format, ...) [NSString stringWithFormat:(format), __VA_ARGS__]

#ifdef __cplusplus
extern "C" {
#endif	
	int mapStringsToInt(NSString* str, NSString** strs, int* ints, int count, int defaultInt);
	NSString* mapIntsToString(int value, NSString** strs, int* ints, int count, NSString* defaultString);
#ifdef __cplusplus
}
#endif	

typedef struct RawData
{
	char* data;
	int len;
} RawData;
	
static inline RawData MakeRawData(char* data, int len)
{
	RawData res = {data, len};
	return res;
}

extern float SCREEN_WIDTH;
extern float SCREEN_HEIGHT;

extern const int LEFT;
extern const int HCENTER;
extern const int RIGHT;
extern const int TOP;
extern const int VCENTER;
extern const int BOTTOM;

extern const int CENTER;

// color structure
typedef struct RGBAColor 
{
	float r, g, b, a;
} RGBAColor;

// color helper
static inline RGBAColor MakeRGBA(const float r, const float g, const float b, const float a)
{
    RGBAColor color = {r, g, b, a};
    return color;
}

#define RGBA_FROM_HEX(RED,GREEN,BLUE,ALPHA) {RED / 255.0, GREEN / 255.0, BLUE / 255.0, ALPHA / 255.0 }

static inline bool RGBAEqual(const RGBAColor a, const RGBAColor b)
{
	return (a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a);
}

extern const RGBAColor transparentRGBA;
extern const RGBAColor solidOpaqueRGBA;;

extern const RGBAColor redRGBA;
extern const RGBAColor blueRGBA;
extern const RGBAColor greenRGBA;
extern const RGBAColor blackRGBA;
extern const RGBAColor whiteRGBA;

typedef struct Rectangle
{
	float x, y, w, h;
} Rectangle;

// rect helper
static inline Rectangle MakeRectangle(const float x, const float y, const float w, const float h)
{
	Rectangle rect = {x, y, w, h};
	return rect;
}

// Quads are primarly used in opengl drawing routines
// 2D quad
typedef struct Quad2D 
	{
		float	tlX, tlY;
		float	trX, trY;
		float	blX, blY;
		float	brX, brY;
	} Quad2D;

// 3D quad
typedef struct Quad3D 
	{
		float	blX, blY, blZ;
		float	brX, brY, brZ;
		float	tlX, tlY, tlZ;
		float	trX, trY, trZ;
	} Quad3D;

// quad helpers
static inline Quad2D MakeQuad2D(const float x, const float y, const float w, const float h)
{
    Quad2D quad = {x, y, x + w, y, x, y + h, x + w, y + h};
    return quad;
}

static inline Quad3D MakeQuad3D(const float x, const float y, const float z, const float w, const float h)
{
    Quad3D quad = {x, y, z, x + w, y, z, x, y + h, z, x + w, y + h, z};
    return quad;
}

// point sprite
typedef struct PointSprite
	{
		float x;
		float y;
		float size;
	} PointSprite;

// point sprite helper
static inline PointSprite MakePointSprite(const float x, const float y, const float size)
{
    PointSprite ps = {x, y, size};
    return ps;
}
