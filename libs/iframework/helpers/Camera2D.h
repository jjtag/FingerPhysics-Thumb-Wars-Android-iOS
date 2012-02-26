//
//  Camera2D.h
//  blockit
//
//  Created by Mac on 07.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MathHelper.h"

// camera object used in 2d scrolling
// SPEED_DELAY mode:  camera will reach the target position in 1/speed seconds
// SPEED_PIXELS mode:  camera will move with speed pixels per second

enum {CAMERA_SPEED_PIXELS, CAMERA_SPEED_DELAY};

@interface Camera2D : NSObject 
{
@public
	int type;

	int speed;
	Vector pos;
	Vector target;
	Vector offset;
}

-(id)initWithSpeed:(int)s andType:(int)t;
-(void)moveToX:(float)x Y:(float)y Immediate:(bool)immediate;
-(void)update:(TimeType)delta;

-(void)applyCameraTransformation;
-(void)cancelCameraTransformation;
@end
