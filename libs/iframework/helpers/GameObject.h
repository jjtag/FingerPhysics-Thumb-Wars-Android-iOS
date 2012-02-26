//
//  GameObject.h
//  buck
//
//  Created by Mac on 26.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Animation.h"
#import "Mover.h"
#import "FrameworkTypes.h"
#import "MathHelper.h"
#import "Debug.h"

@interface GameObject : Animation 
{
@public

	int state;
	int type;
	
	Mover* mover;
	Rectangle bb;
	Quad2D rbb;
	
	bool rotatedBB;
	bool isDrawBB;
	
@private
	
	bool topLeftCalculated;
}

-(id)initWithTextureID:(int)t xOff:(int)tx yOff:(int)ty XML:(XMLNode*)xml;
-(void)parseMover:(XMLNode*)xml;
-(void)setMover:(Mover*)m;
-(void)rotateWithBB:(float)a;
-(void)drawBB;

@end

#ifdef __cplusplus
extern "C" {
#endif
bool objectsIntersect(GameObject* o1, GameObject* o2);
bool objectsIntersectRotated(GameObject* o1, GameObject* o2);
bool pointInObject(Vector p, GameObject* o);
#ifdef __cplusplus
}
#endif