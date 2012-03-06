//
//  FPCamera2D.h
//  champions
//
//  Created by ikoryakin on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Camera2D.h"
#import "Vector.h"

@interface FPCamera2D : Camera2D
{
	BOOL delegateNotified;
//	id <CameraPathProtocol> pathDelegate;
	Vector* path;
	int pathIndex;
	int pathCount;
	int pathCapacity;
@public
	BOOL pathEnabled;
}

-(void)turnMaxPathPoints:(int)maxPath;
-(void)startPath;
-(void)addPathPoint:(Vector)point;
-(void)turnMaxPathPoints:(int)maxPath;

@end
