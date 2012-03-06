//
//  FPCamera2D.m
//  champions
//
//  Created by ikoryakin on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FPCamera2D.h"
#import "Debug.h"
#import <OpenGLES/ES1/gl.h>

@implementation FPCamera2D

-(id)initWithSpeed:(int)s andType:(int)t;
{
	if (self = [super init])
	{
		ASSERT(s > 0);
		speed = s;
		type = t;
		delegateNotified = FALSE;
		pathCount = 0;
		pathCapacity = 0;
	}
	
	return self;
}

-(void)turnMaxPathPoints:(int)maxPath
{
	ASSERT(!path);
	pathCapacity = maxPath;
	path = malloc(sizeof(Vector) * pathCapacity);	
}

-(void)addPathPoint:(Vector)point
{
	ASSERT(pathCount < pathCapacity);
	path[pathCount] = point;
	pathCount++;
}

-(void)startPath
{
	if(pathCount == 0)return;
	pathIndex = 0;
	pathEnabled = TRUE;
	Vector p = path[pathIndex];
	pathIndex++;
	[self moveToX:p.x Y:p.y Immediate:TRUE];
}

-(void)cameraReachedTargetPoint:(Vector)point
{
	if(pathEnabled)
	{
		if(pathIndex < pathCount)
		{
			Vector p = path[pathIndex++];
			[self moveToX:p.x Y:p.y Immediate:FALSE];
		}
		else
		{
			pathEnabled = FALSE;
		}
	}
}

-(void)dealloc
{
	if(path)
		free(path);
	[super dealloc];
}

-(void)moveToX:(float)x Y:(float)y Immediate:(bool)immediate
{
	target.x = x;
	target.y = y;
	
	if(pathEnabled)
	{
		Vector p = path[pathIndex-1];
		if(!vectEqual(target, p))
		{
			pathEnabled = FALSE;
		}
	}
	
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
		delegateNotified = FALSE;
	}
	else
	{
		if(!delegateNotified)
		{
			[self cameraReachedTargetPoint:target];
			delegateNotified = TRUE;
		}
	}
}

-(void)applyCameraTransformation
{
	glTranslatef(pos.x, pos.y, 0.0);
}

-(void)cancelCameraTransformation
{
	glTranslatef(-pos.x, -pos.y, 0.0);	
}

@end
