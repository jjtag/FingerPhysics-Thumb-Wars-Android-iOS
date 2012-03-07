//
//  AnimationStrip.m
//  blockit
//
//  Created by Efim Voinov on 24.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Animation.h"
#import "../support/Texture2D.h"
#import "Framework.h"

@implementation Animation

//-(int)addAnimationWithDelay:(float)d Looped:(bool)l Count:(int)c Sequence:(int)s,...
//{
//	va_list argumentList;
//	va_start(argumentList, s); 
//	
//	int index = [timelines count];
//	[self addAnimationWithID:index Delay:d Loop:l Count:c First:s Last:UNDEFINED ArgumentList:argumentList];
//	return index;
//}
//
//-(void)addAnimationWithID:(int)aid Delay:(float)d Loop:(int)l Count:(int)c Sequence:(int)s,...
//{
//	va_list argumentList;
//	va_start(argumentList, s); 
//
//	[self addAnimationWithID:aid Delay:d Loop:l Count:c First:s Last:UNDEFINED ArgumentList:argumentList];	
//}
//
//-(int)addAnimationDelay:(float)d Loop:(int)l First:(int)s Last:(int)e
//{	
//	int index = [timelines count];	
//	[self addAnimationWithID:index Delay:d Loop:l First:s Last:e];	
//	return index;	
//}
//
//-(void)addAnimationWithID:(int)aid Delay:(float)d Loop:(int)l First:(int)s Last:(int)e
//{	
//	int c = e - s + 1;
//	ASSERT(c > 0);
//	[self addAnimationWithID:aid Delay:d Loop:l Count:c First:s Last:e ArgumentList:nil];	
//}

//-(void)addAnimationWithID:(int)aid Delay:(float)d Loop:(int)l Count:(int)c First:(int)s Last:(int)e ArgumentList:(va_list)al
//{
//	Timeline* t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:c + 2];
//		
//	DynamicArray* as = [[DynamicArray allocAndAutorelease] init];
//	[as addObject:createAction(self, (NSString*)ACTION_SET_DRAWQUAD, s, 0)];
//	[t addKeyFrame:makeAction(as, 0.0)];
//	int si = s;
//	
//	for (int i = 1; i < c; i++)
//	{                  
//		
//		if (al)
//		{
//			si = va_arg(al, int);
//		}
//		else
//		{
//			si++;
//		}
//		
//		DynamicArray* as = [[DynamicArray allocAndAutorelease] init];
//		[as addObject:createAction(self, (NSString*)ACTION_SET_DRAWQUAD, si, 0)];
//		[t addKeyFrame:makeAction(as, d)];
//		
//		if (i == c - 1 && l == TIMELINE_REPLAY)
//		{
//			[t addKeyFrame:makeAction(as, d)];			
//		}
//	}
//	
//	if (al)
//	{
//		va_end(al);		
//	}
//	
//	if (l)
//	{
//		[t setTimelineLoopType:l];
//	}	
//	
//	[self addTimeline:t withID:aid];
//}

-(void)addAnimationWithID:(int)aid Delay:(float)d Loop:(int)l Count:(int)c Sequence:(int*)sequece
{
	Timeline* t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:c + 2];
    
	DynamicArray* as = [[DynamicArray allocAndAutorelease] init];
	[as addObject:createAction(self, (NSString*)ACTION_SET_DRAWQUAD, sequece[0], 0)];
	[t addKeyFrame:makeAction(as, 0.0)];
	
	for (int i = 1; i < c; i++)
	{                  
		DynamicArray* as = [[DynamicArray allocAndAutorelease] init];
		[as addObject:createAction(self, (NSString*)ACTION_SET_DRAWQUAD, sequece[i], 0)];
		[t addKeyFrame:makeAction(as, d)];
		
		if (i == c - 1 && l == TIMELINE_REPLAY)
		{
			[t addKeyFrame:makeAction(as, d)];			
		}
	}
	
	if (l)
	{
		[t setTimelineLoopType:l];
	}	
	
	[self addTimeline:t withID:aid];
}

-(void)setDelay:(TimeType)d atIndex:(int)i forAnimation:(int)a
{
	Timeline* t = [self getTimeline:a];
	ASSERT(t);
	Track* track = [t getTrack:TRACK_ACTION];
	ASSERT(track);
	ASSERT(i >= 0 && i < track->keyFramesCount);
	KeyFrame* kf = &track->keyFrames[i];
	kf->timeOffset = d;
}

-(void)setPauseAtIndex:(int)i forAnimation:(int)a
{
	[self setAction:(NSString*)ACTION_PAUSE_TIMELINE Target:self Param:0 SubParam:0 AtIndex:i forAnimation:a];
}

-(void)setAction:(NSString*)action Target:(BaseElement*)target Param:(int)p SubParam:(int)sp AtIndex:(int)i forAnimation:(int)a
{
	Timeline* t = [self getTimeline:a];
	ASSERT(t);
	Track* track = [t getTrack:TRACK_ACTION];
	ASSERT(track);
	ASSERT(i >= 0 && i < track->keyFramesCount);
	KeyFrame kf = track->keyFrames[i];
	DynamicArray* ar = kf.value.action.actionSet;
	[ar addObject:createAction(target, action, p, sp)];	
}

-(void)switchToAnimation:(int)a2 atEndOfAnimation:(int)a1 Delay:(TimeType)d
{
	Timeline* t = [self getTimeline:a1];
	ASSERT(t);
	DynamicArray* as = [[DynamicArray allocAndAutorelease] init];
	ASSERT(a2 >= 0 && a2 < [timelines count]);
	[as addObject:createAction(self, (NSString*)ACTION_PLAY_TIMELINE, 0, a2)];
	[t addKeyFrame:makeAction(as, d)];
}


// go to the specified sequence frame of the current animation
-(void)jumpTo:(int)i
{
	Timeline* t = [self getCurrentTimeline];
	ASSERT(t);
	[t jumpToTrack:TRACK_ACTION KeyFrame:i];
}

@end
