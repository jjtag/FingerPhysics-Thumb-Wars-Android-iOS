//
//  FPBody.h
//  champions
//
//  Created by ikoryakin on 3/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D.h>
#import "FPShape.h"
#import "FPCircleShape.h"
#import "DynamicArray.h"
#import "Framework.h"

#define PTM_RATIO 10

struct Texels {
	float* texels;
	float* highlight_texels;
	float* lowlight_texels;
};

@interface FPBody : NSObject <NSCopying> {
	NSString* name;
	
	b2Body* body;
	DynamicArray* shapes;
	
	Vector pos;
	Vector massCenter;
	
	float mass;
	float angle;
	float inertia;
	
	int queue;
	int uniqId;
	
	BOOL isStatic;
	BOOL isFixedRotation;
	BOOL isTouchable;
	BOOL isBreakable;
	BOOL isPinned;
	Texture2D* texture;
	Texture2D* lightTexture;
	id userData;
	float* outlineVerts;
	int outlineVertexCount;
	@public
	BOOL isExplodable;
	int charge;
	Image* sprite;
	Vector force;
	Vector forceOffset;
	Vector arrowOffset;
	Texture2D* arrowTexture;
	BOOL gravity;
	@public
	RGBAColor blockColor;
	RGBAColor blockBackColor;
	RGBAColor outlineColor;
}
-(void)setSprite:(Image*)spr;
-(void)update:(TimeType)delta;
-(void)draw;
-(void)drawBodyOutlines;
-(void)drawShapesShadow;

-(void)setTexture:(Texture2D*)t;
-(void)setLightTexture:(Texture2D*)t;
-(void)setTexelsForTexture:(Texture2D*)t;
-(void)allocOutlineVerts:(int)vertexCount;
-(void)releaseOutlineVerts;

@property (nonatomic, retain) NSString* name;
@property (assign) b2Body* body;
@property (retain) DynamicArray* shapes;

@property (assign) Vector pos, massCenter;

@property (assign) float mass, angle, inertia;
@property (assign) int queue, outlineVertexCount, uniqId;
@property (assign) BOOL isStatic, isFixedRotation, isTouchable, isBreakable, isPinned;
@property (assign) RGBAColor blockColor, blockBackColor, outlineColor;
@property (assign) id userData;
@property (assign) float* outlineVerts;
@end
