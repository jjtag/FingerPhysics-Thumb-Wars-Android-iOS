//
//  ShockWave.h
//  blockit
//
//  Created by Alexander Roslyakov on 6/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "Framework.h"

@interface ShockWave : NSObject
{
@public
	Vector position;
	float initialRadius;
	float currentRadius;
	float initialImpulse;	// impulse that will be applied to bodies
	RGBAColor color;
}

-(id)initWith:(Vector)pos andWidth:(float)width andImpulseFactor:(float)impulseFactor;
-(void)draw;

@end
