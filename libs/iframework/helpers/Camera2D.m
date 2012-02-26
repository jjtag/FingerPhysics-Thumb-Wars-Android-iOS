//
//  Camera2D.m
//  blockit
//
//  Created by Mac on 07.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Camera2D.h"
#import "Debug.h"
#import <OpenGLES/ES1/gl.h>

@implementation Camera2D

-(id)initWithSpeed:(int)s andType:(int)t;
{
	if (self = [super init])
	{
		ASSERT(s > 0);
		speed = s;
		type = t;
	}
	
	return self;
}

-(void)moveToX:(float)x Y:(float)y Immediate:(bool)immediate
{
	target.x = x;
	target.y = y;

	if (immediate)
	{
		pos = target;
	}
	else if (type == CAMERA_SPEED_DELAY)
	{
		offset = vectMult(vectSub(target, pos), speed);		
	}
	else if (type == CAMERA_SPEED_PIXELS)
	{
		offset = vectMult(vectNormalize(vectSub(target, pos)), speed);
	}
	
}

-(void)update:(TimeType)delta
{
	if (!vectEqual(pos, target))
	{
		pos = vectAdd(pos, vectMult(offset, delta));
		
		// check if we passed the target
		if (!sameSign(offset.x, target.x - pos.x) || !sameSign(offset.y, target.y - pos.y))
		{
			pos = target;
		}
	}
}

-(void)applyCameraTransformation
{
	glTranslatef(-pos.x, -pos.y, 0.0);
}

-(void)cancelCameraTransformation
{
	glTranslatef(pos.x, pos.y, 0.0);	
}

@end
