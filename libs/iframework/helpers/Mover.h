//
//  Mover.h
//  rogatka
//
//  Created by Efim Voinov on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FrameworkTypes.h"

// class represents entity moving along the specified path with speed and rotation
@interface Mover : NSObject 
{
	float* moveSpeed; // pixels / second
	float rotateSpeed; // radians / second
	
@public
	Vector* path;
	int pathLen;
	int pathCapacity;	
	Vector pos;
	double angle;
	bool paused;
	int targetPoint;	
	
	// reverse movement
	bool reverse;
	
@private
	float overrun;	
	Vector offset;
	
}
-(id)initWithPathCapacity:(int)l MoveSpeed:(int)m RotateSpeed:(int)r;
-(void)addPathPoint:(Vector)v;
-(void)jumpToPoint:(int)p;
-(void)setMoveSpeed:(float)ms forPoint:(int)i;
-(void)setRotateSpeed:(float)rs;
-(void)setMoveReverse:(bool)r;
-(void)setPathFromString:(NSString*)path andStart:(Vector)s;
-(void)start;
-(void)pause;
-(void)unpause;
-(void)update:(TimeType)delta;
@end

// lightweight c function which moves v to t with specified speed per second
void moveVariableToTarget(float* v, float t, float speed, float delta);