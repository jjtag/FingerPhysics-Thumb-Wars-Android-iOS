//
//  FPShape.h
//  champions
//
//  Created by ikoryakin on 3/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D.h>
#import "Framework.h"

@interface FPShape : NSObject <NSCopying> {
	Vector offset;
	float angle;
	float friction;
	float density;
	float restitution;
	BOOL isSensor;
	BOOL isVisible;
	@public
	float* texels;
}

-(void)copyAttributesFrom:(FPShape*)shape;

@property (assign) Vector offset;
@property (assign) float angle, friction, density, restitution;
@property (assign) BOOL isSensor, isVisible;
@end
