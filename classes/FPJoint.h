//
//  FPJoint.h
//  champions
//
//  Created by ikoryakin on 4/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector.h"
#import "FPBody.h"

enum Joint_Types
{
	JOINT_NONE = 0,
	JOINT_PINNED,
	JOINT_GEARED,
	JOINT_DISTANCE,
};

@interface FPJoint : NSObject
{
	@public
	int type;
	float rotationSpeed;
	float maxMotorTorque;
	Vector rotationOffset;
	Vector offsetBody1;
	Vector offsetBody2;
	int body1Id;
	int body2Id;
	float dampingRatio;
	float freqHz;
	BOOL collideConnected;	
}

@end
