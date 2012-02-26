//
//  Mover.m
//  rogatka
//
//  Created by Efim Voinov on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Mover.h"
#import "Framework.h"

@interface Mover (Private)
-(void)calculateOffset;
@end


@implementation Mover

-(id)initWithPathCapacity:(int)l MoveSpeed:(int)m RotateSpeed:(int)r;
{
	if (self = [super init])
	{
		pathLen = 0;
		pathCapacity = l;
		rotateSpeed = r;
		if (pathCapacity > 0)
		{
			path = malloc(sizeof(Vector) * pathCapacity);
			moveSpeed = malloc(sizeof(float) * pathCapacity);			
			for (int i = 0; i < pathCapacity; i++)
			{
				moveSpeed[i] = m;
			}
		}
		
		paused = FALSE;
	}
	
	return self;
}

-(void)setPathFromString:(NSString*)p andStart:(Vector)s
{
	if ([p characterAtIndex:0] == 'R')
	{
		bool clockwise = ([p characterAtIndex:1] == 'C');
		NSString* newPath = [p substringFromIndex:2];
		int rad = [newPath intValue];
		int pointsCount = rad / 2;
		float k_increment = 2.0f * M_PI / pointsCount;
		if (!clockwise) k_increment = -k_increment;
		float theta = 0.0f;
		
		for (int i = 0; i < pointsCount; ++i)
		{
			float nx = s.x + rad * cosf(theta);
			float ny = s.y + rad * sinf(theta);
			[self addPathPoint:vect(nx, ny)];
			theta += k_increment;
		}		
	}
	else
	{
		[self addPathPoint:s];
		if ([p characterAtIndex:([p length] - 1)] == ',')
		{
			p = [p substringToIndex:[p length] - 1];
		}
		NSArray* parts = [p componentsSeparatedByString:@","];
		ASSERT([parts count] % 2 == 0);
		for (int i = 0; i < [parts count]; i += 2)
		{
			NSString* xs = [parts objectAtIndex:i];
			NSString* ys = [parts objectAtIndex:i + 1];			
			[self addPathPoint:vect(s.x + [xs floatValue], s.y + [ys floatValue])];
		}
	}
}

-(void)addPathPoint:(Vector)v
{
	path[pathLen++] = v;
	ASSERT(pathLen <= pathCapacity);
}
	
-(void)start
{
	if (pathLen > 0)
	{		
		pos = path[0];
		targetPoint = 1;
		[self calculateOffset];
	}	
}

-(void)pause
{
	paused = TRUE;	
}

-(void)unpause
{
	paused = FALSE;
}

-(void)setRotateSpeed:(float)rs
{
	rotateSpeed = rs;
}

-(void)jumpToPoint:(int)p
{
	ASSERT(p >= 0 && p < pathLen);
	targetPoint = p;
	pos = path[targetPoint];
	
	[self calculateOffset];			
}

-(void)calculateOffset
{
	Vector target = path[targetPoint];
	offset = vectMult(vectNormalize(vectSub(target, pos)), moveSpeed[targetPoint]);	
}

-(void)setMoveSpeed:(float)ms forPoint:(int)i
{
	ASSERT(i >= 0 && i < pathCapacity);
	moveSpeed[i] = ms;
}

-(void)setMoveReverse:(bool)r
{
	reverse = r;
}

-(void)update:(TimeType)delta
{
	if (paused)
	{
		return;
	}
	
	if (pathLen > 0)
	{	
		Vector target = path[targetPoint];
		bool switchPoint = FALSE;
		
		if (!vectEqual(pos, target))
		{
	
			float rdelta = delta;
			if (overrun != 0)
			{
				rdelta += overrun;
				overrun = 0;
			}
			
			pos = vectAdd(pos, vectMult(offset, rdelta));
			
			// check if we passed the target
			if (!sameSign(offset.x, target.x - pos.x) || !sameSign(offset.y, target.y - pos.y))
			{
				overrun = vectLength(vectSub(pos, target));
				float olen = vectLength(offset);
				// overrun in seconds
				overrun = overrun / olen;
				pos = target;
				switchPoint = TRUE;
			}
		}
		else
		{
			switchPoint = TRUE;
		}

		if (switchPoint)
		{
			if (reverse)
			{
				targetPoint--;
				if (targetPoint < 0)
				{
					targetPoint = pathLen - 1;
				}				
			}
			else
			{
				targetPoint++;
				if (targetPoint >= pathLen)
				{
					targetPoint = 0;
				}
			}
			
			[self calculateOffset];			
			/*if (overrun != 0)
			{
				Vector unit = vectNormalize(vectSub(path[targetPoint], pos));
				pos = vectAdd(pos, vectMult(unit, overrun));
				overrun = 0;
			}*/	
		}
	}
	
	if (rotateSpeed != 0)
	{
		angle += rotateSpeed * delta;
	}
}

-(void)dealloc
{
	if (path)
	{
		free(path);
	}
	if (moveSpeed)
	{
		free(moveSpeed);
	}
	[super dealloc];
}
@end

void moveVariableToTarget(float* v, float t, float speed, float delta)
{
	if (t != *v)
	{
		if (t > *v)
		{
			*v += speed * delta;
			if (*v > t)
			{
				*v = t;
			}
		}
		else
		{
			*v -= speed * delta;
			if (*v < t)
			{
				*v = t;
			}			
		}
	}	
}
