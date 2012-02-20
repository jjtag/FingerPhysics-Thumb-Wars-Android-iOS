//
//  TextScores.m
//  champions
//
//  Created by ikoryakin on 6/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TextScores.h"


@implementation TextScores
@synthesize points;

+(id)createWithFont:(Font*)i points:(int)points prefix:(NSString*)prefix
{
	TextScores* t = [[[self class] allocAndAutorelease] initWithFont:i];
	t.points = points;
	if(prefix)
		[t setString:FORMAT_STRING(@"%@%i", prefix, points)];
	else
		[t setString:@" "];
	return t;
}

-(id)initWithFont:(Font *)i
{
	if(self = [super initWithFont:i])
	{
		points = 0;
		pointsStruct = nil;
		animationStarted = FALSE;
		animCount = 0;
		animCapacity = 0;
	}
	return self;
}

-(void)addPointsAnim:(int)p inTime:(float)sec prefix:(NSString*)prefix
{
	ASSERT(pointsStruct);
	ASSERT(sec != 0);
	ASSERT(animCount < animCapacity);
	int originPoints = 0;
	if(animCount > 0)
		originPoints = pointsStruct[animCount-1].originPoints+pointsStruct[animCount-1].addPoints;
	else
		originPoints = points;
	AnimPointsStruct s = {p, originPoints, sec, prefix};
	pointsStruct[animCount] = s;
	animCount++;
	[prefix retain];
}

-(void)turnMaxAnimSteps:(int)s
{
	ASSERT(!pointsStruct);
	pointsStruct = malloc(sizeof(AnimPointsStruct) * s);
	animCapacity = s;
}

-(void)start
{
	animationStarted = TRUE;
	currentAnim = 0;
	timePassed = 0;
}

-(void)stop
{
	animationStarted = FALSE;
	if(animCapacity > 0)
	{
		points = pointsStruct[animCount-1].originPoints + pointsStruct[animCount-1].addPoints;
		if(pointsStruct[animCount-1].prefix)
		{
			color.a = 1;
			[self setString:FORMAT_STRING(@"%@%i", pointsStruct[animCount-1].prefix, points)];
		}
		else
			[self setString:@" "];
	}
}

-(void)setPoints:(int)p prefix:(NSString*)prefix
{
	points = p;
	if(prefix)
	{
		color.a = 1;
		[self setString:FORMAT_STRING(@"%@%i", prefix, points)];
	}
	else
		[self setString:@" "];
}

-(void)update:(TimeType)delta
{
	[super update:delta];
	if(animationStarted && currentAnim < animCount)
	{
		if(pointsStruct[currentAnim].prefix)
		{
			[self setString:FORMAT_STRING(@"%@%i", pointsStruct[currentAnim].prefix, points)];
			color.a = 1;
		}
		else
			color.a -= 0.1;
		if(timePassed <= pointsStruct[currentAnim].time)
		{
			timePassed += delta;
			float additionalPoints = (pointsStruct[currentAnim].addPoints * MIN(1,(timePassed/pointsStruct[currentAnim].time)));
			points = pointsStruct[currentAnim].originPoints + additionalPoints;
		}
		else
		{
			currentAnim++;
			timePassed = 0;
		}
	}
	else
	{
		[self stop];
	}
}

-(void)dealloc
{
	if(pointsStruct)
		free(pointsStruct);
	[super dealloc];
}
@end
