//
//  TextScores.h
//  champions
//
//  Created by ikoryakin on 6/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Framework.h"

typedef struct AnimPointsStruct
{
	int addPoints;
	int originPoints;
	TimeType time;
	NSString* prefix;
} AnimPointsStruct;

@interface TextScores : Text 
{
	int points;
	int currentAnim;
	int animCount;
	int animCapacity;
	AnimPointsStruct* pointsStruct;
	BOOL animationStarted;
	TimeType timePassed;
}
+(id)createWithFont:(Font*)i points:(int)points prefix:(NSString*)prefix;
-(void)turnMaxAnimSteps:(int)s;
-(void)addPointsAnim:(int)p inTime:(float)sec prefix:(NSString*)prefix;
-(void)start;
-(void)stop;
-(void)setPoints:(int)p prefix:(NSString*)prefix;

@property (assign) int points;
@end
