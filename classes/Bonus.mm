//
//  Bonus.m
//  champions
//
//  Created by ikoryakin on 4/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "ChampionsResourceMgr.h"
#import "Bonus.h"
#import <Box2D.h>

@implementation Bonus
@synthesize shadow;
@synthesize body;
@synthesize mode;
@synthesize collected;
@synthesize timer;

-(id)initWithTexture:(Texture2D*)t
{
	if(self = [super initWithTexture:t])
	{
		Timeline* t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:3];
		[t addKeyFrame:makeScale(1.0, 1.0, FRAME_TRANSITION_LINEAR, 0.0)];
		[t addKeyFrame:makeScale(1.2, 1.2, FRAME_TRANSITION_LINEAR, 0.5)];
		[t addKeyFrame:makeScale(1.0, 1.0, FRAME_TRANSITION_LINEAR, 0.8)];
		[t setTimelineLoopType:TIMELINE_REPLAY];
		[t setDelegate:self];
		[self addTimeline:t withID:BONUS_ACTIVE_TIMELINE];
		
		Timeline* timeline_vanish = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:2];
//		[timeline_vanish addKeyFrame:makeScale(1.0, 1.0, FRAME_TRANSITION_LINEAR, 0.2)];
		[timeline_vanish addKeyFrame:makeScale(1.2, 1.2, FRAME_TRANSITION_LINEAR, 0)];
		[timeline_vanish addKeyFrame:makeScale(0.0, 0.0, FRAME_TRANSITION_LINEAR, 0.7)];
		[timeline_vanish setTimelineLoopType:TIMELINE_NO_LOOP];
		[self addTimeline:timeline_vanish withID:BONUS_VANISH_TIMELINE];
		
		Timeline* timeline_collect = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:2];
		[timeline_collect addKeyFrame:makeRotation(0, FRAME_TRANSITION_LINEAR, 0)];
		[timeline_collect addKeyFrame:makeRotation(360, FRAME_TRANSITION_LINEAR, 0.7f)];
		[timeline_collect setDelegate:self];
		[self addTimeline:timeline_collect withID:BONUS_COLLECT_TIMELINE];
		
		Animation* a = [[Animation allocAndAutorelease] initWithTexture:[ChampionsResourceMgr getResource:IMG_STARS_ANIM]];	
		a->anchor = a->parentAnchor = CENTER;
		[a addAnimationWithID:0 Delay:0.1 Loop:TIMELINE_REPLAY Count:6 Sequence:IMG_STARS_ANIM_ANIM1,IMG_STARS_ANIM_ANIM2,IMG_STARS_ANIM_ANIM2,IMG_STARS_ANIM_ANIM2,IMG_STARS_ANIM_ANIM2,IMG_STARS_ANIM_ANIM2];
		[a playTimeline:0];
		rotationCenterY = -1;
		rotationCenterX = -4;
		[a setEnabled:FALSE];
		[self addChild:a];
	}
	return self;
}

-(void)dealloc
{
	[shadow release];
	[super dealloc];
}

//-(void)postDraw
//{
//	[super postDraw];
//	glDisable(GL_TEXTURE_2D);
//	glDisable(GL_BLEND);
//	float rotationOffsetX = drawX + (width >> 1) + rotationCenterX;
//	float rotationOffsetY = drawY + (height >> 1) + rotationCenterY;
//	drawPoint(rotationOffsetX, rotationOffsetY, 1, redRGBA);
//	glColor4f(1, 1, 1, 1);
//	glEnable(GL_BLEND);
//	glEnable(GL_TEXTURE_2D);
//}

-(void)drawShadow
{
	ASSERT(shadow);
	shadow->anchor = anchor;
	shadow->parentAnchor = parentAnchor;
	shadow->rotation = rotation;
//	shadow->drawX = drawX;
//	shadow->drawY = drawY;
	shadow->x = x;
	shadow->y = y;
	shadow->scaleX = scaleX;
	shadow->scaleY = scaleY;
	shadow->rotationCenterX = rotationCenterX;
	shadow->rotationCenterY = rotationCenterY;
	float offset = 10;
	glTranslatef(offset, offset, 0);
	[shadow draw];
	glTranslatef(-offset, -offset, 0);	
}

-(void)update:(TimeType)delta
{
	[super update:delta];
	b2Vec2 center = body.body->GetPosition();
	center *= PTM_RATIO;
	x = center.x;
	y = center.y;
}

-(void)setMode:(int)m
{
	ASSERT(m >= MODE_STATIC && m <= MODE_VANISHED);
	switch (m)
	{
		case MODE_ACTIVE:
		{
			if (mode != MODE_ACTIVE && ([self getCurrentTimelineIndex] != BONUS_ACTIVE_TIMELINE || [self getCurrentTimelineIndex] != BONUS_COLLECT_TIMELINE || [self getCurrentTimeline]->state != TIMELINE_PLAYING) )
			{
				[self playTimeline:BONUS_COLLECT_TIMELINE];
				BaseElement* a = [self getChild:0];
				[a setEnabled:TRUE];
				[self setDrawQuad:IMG_STARS_ANIM_GOLD];
			}
			break;
		}
		case MODE_VANISH:
		{
			break;
		}
		case MODE_STATIC:
		{
			rotation = 0;
			[self setDrawQuad:IMG_STARS_ANIM_SILVER];
			BaseElement* a = [self getChild:0];
			[a setEnabled:FALSE];
			if([self getCurrentTimeline])
				[self pauseCurrentTimeline];
			break;
		}
		default:
			break;
	}
	mode = m;
}

-(void)timelineFinished:(Timeline*)t
{
//	if(t == [self getTimeline:BONUS_ACTIVE_TIMELINE])
//	{
//		NSLog(@"a");
//		if(mode == MODE_VANISH)
//		{
////			[self playTimeline:BONUS_VANISH_TIMELINE];
////			BaseElement* a = [self getChild:0];
////			[a setEnabled:FALSE];
//		}
//		else
//		{
//			[self playTimeline:BONUS_ACTIVE_TIMELINE];
//		}
//		
//	}
//	else 
//	{
		if(t == [self getTimeline:BONUS_COLLECT_TIMELINE])
		{
			BaseElement* a = [self getChild:0];
			[a setEnabled:FALSE];
			[self playTimeline:BONUS_ACTIVE_TIMELINE];
		}
//	}
}

-(void)timeline:(Timeline*)t reachedKeyFrame:(KeyFrame*)k withIndex:(int)i
{
	if(mode == MODE_VANISH && t == [self getTimeline:BONUS_ACTIVE_TIMELINE] && i == 1)
	{
		[self playTimeline:BONUS_VANISH_TIMELINE];
		BaseElement* a = [self getChild:0];
		[a setEnabled:FALSE];
	}
}

@end
