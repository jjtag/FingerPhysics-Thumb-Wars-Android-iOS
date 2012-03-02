//
//  FPSettings.h
//  champions
//
//  Created by ikoryakin on 3/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D.h>
#import "Framework.h"

@interface FPSettings : NSObject {
	Vector gravity;
	NSString* description;
	float width;
	float height;
	int mode;
	int iterations;
	float maxMouseForce;
	@public
	int magnetFreqHz;
	float magnetDampingRatio;
	int magnetImpulseMultiplier;
	int magnetMinJointDistance;
	float mouseBodyMass;
	float shockWaveWidth;
	int shockWaveSpeed;
	float shockWaveImpulseFactor;
	float shockWaveMaxRadius;
	float maxShockWaveBodyVelocity;
}

@property (assign) Vector gravity;
@property (nonatomic, retain) NSString* description;
@property (assign) float Width, Height, maxMouseForce;
@property (assign) int mode, iterations;
@end
