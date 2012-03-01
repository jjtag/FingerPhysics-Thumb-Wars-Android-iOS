//
//  Baloon.m
//  champions
//
//  Created by Mac on 21.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Baloon.h"
#import "MenuController.h"
#import "ChampionsResourceMgr.h"

enum {SHOW_TIMELINE, HIDE_TIMELINE};

@implementation Baloon

+(void)setBaloonAnimations:(Baloon*)activeBaloon
{
	Timeline* t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:3];
	[t addKeyFrame:makeScale(0.0, 0.0, FRAME_TRANSITION_LINEAR, 0.0)];
	[t addKeyFrame:makeScale(1.1, 1.1, FRAME_TRANSITION_EASE_OUT, 0.15)];
	[t addKeyFrame:makeScale(1.0, 1.0, FRAME_TRANSITION_EASE_OUT, 0.05)];	
	[t addKeyFrame:makePos(100.0, 0.0, FRAME_TRANSITION_LINEAR, 0.0)];
	[t addKeyFrame:makePos(-20.0, 0.0, FRAME_TRANSITION_EASE_OUT, 0.2)];
	[activeBaloon->baloonBack addTimeline:t withID:SHOW_TIMELINE];
	
	if (activeBaloon->type != BALOON_STATIC)
	{
		[activeBaloon->baloonBack playTimeline:SHOW_TIMELINE];
	}
	
	t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:2];
	[t addKeyFrame:makePos(240.0, 140.0, FRAME_TRANSITION_EASE_OUT, 0.0)];
	[t addKeyFrame:makePos(100.0, 140.0, FRAME_TRANSITION_EASE_OUT, 0.2)];
	[activeBaloon->charImage addTimeline:t withID:SHOW_TIMELINE];
	
	if (activeBaloon->type == BALOON_SINGLE || activeBaloon->type == BALOON_MULTIPLE_FIRST)
	{
		[activeBaloon->charImage playTimeline:SHOW_TIMELINE];		
	}	
	
	t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:2];
	[t addKeyFrame:makeScale(1.0, 1.0, FRAME_TRANSITION_EASE_IN, 0.0)];
	[t addKeyFrame:makeScale(0.0, 0.0, FRAME_TRANSITION_EASE_IN, 0.2)];
	[t addKeyFrame:makePos(-20.0, 0.0, FRAME_TRANSITION_EASE_OUT, 0.0)];
	[t addKeyFrame:makePos(100.0, 0.0, FRAME_TRANSITION_LINEAR, 0.2)];
	[activeBaloon->baloonBack addTimeline:t withID:HIDE_TIMELINE];
	t->delegate = activeBaloon;
	
	t = [[Timeline allocAndAutorelease] initWithMaxKeyFramesOnTrack:2];
	[t addKeyFrame:makePos(100.0, 140.0, FRAME_TRANSITION_EASE_IN, 0.0)];
	[t addKeyFrame:makePos(240.0, 140.0, FRAME_TRANSITION_EASE_IN, 0.2)];
	[activeBaloon->charImage addTimeline:t withID:HIDE_TIMELINE];	
}

+(void)showBaloonWithID:(int)bID Text:(NSString*)text Image:(Image*)im Blocking:(bool)bl Type:(int)tp inView:(BaseElement*)v Delegate:(id<BaloonDelegate>)dl
{
	Baloon* activeBaloon = [[Baloon allocAndAutorelease] init];
	activeBaloon->anchor = activeBaloon->parentAnchor = BOTTOM | HCENTER;
	[activeBaloon setName:@"baloon"];
	activeBaloon->width = SCREEN_WIDTH;
	activeBaloon->height = SCREEN_HEIGHT;
	
	activeBaloon->baloonID = bID;
	activeBaloon->blocking = bl;
	activeBaloon->type = tp;	
	activeBaloon->delegate = dl;	
	activeBaloon->charImage = im;
	
	activeBaloon->charImage->anchor = CENTER;
	activeBaloon->charImage->parentAnchor = CENTER;
	activeBaloon->charImage->y = 140.0;
	activeBaloon->charImage->x = 100.0;
	activeBaloon->charImage->rotation = -15.0;
	[activeBaloon addChild:activeBaloon->charImage];	
	
	activeBaloon->baloonBack = [Image createWithResID:IMG_BALOON];
	activeBaloon->baloonBack->anchor = activeBaloon->baloonBack->parentAnchor = BOTTOM | HCENTER;
	activeBaloon->baloonBack->x = -20.0;
	[activeBaloon addChild:activeBaloon->baloonBack];
	
	ColoredText* ct = [[ColoredText allocAndAutorelease] initWithFont:[[Application sharedResourceMgr] getResource:FNT_FONTS_001_SMALL]];
	ct->anchor = ct->parentAnchor = CENTER;
	[ct setString:text andWidth:180.0];
	ct->color = MakeRGBA(0.0, 0.0, 0.0, 1.0);
	ct->y = -5.0;
	ct->x = -20.0;

	ASSERT(v);
	[v addChild:activeBaloon];
	
	
	if (activeBaloon->type != BALOON_STATIC)
	{
		calculateTopLeft(activeBaloon);
		
		Button* close = [MenuController createButtonWithImage:((activeBaloon->type == BALOON_SINGLE || activeBaloon->type == BALOON_MULTIPLE_LAST) ? 
															   IMG_BALOON_CLOSE : IMG_BALOON_NEXT_NEWS) ID:BUTTON_CLOSE Delegate:activeBaloon];
		[close forceTouchRect:MakeRectangle(-205.0, activeBaloon->drawY, 205 + SCREEN_WIDTH, activeBaloon->height)];
		close->anchor = close->parentAnchor = BOTTOM | HCENTER;
		close->y = -87.0;
		close->x = 75.0;
		[activeBaloon->baloonBack addChild:close];
	}
	[activeBaloon->baloonBack addChild:ct];		
	
	[Baloon setBaloonAnimations:activeBaloon];	
}

+(void)hideBaloonInView:(BaseElement*)v
{
	Baloon* b = (Baloon*)[v getChildWithName:@"baloon"];
	if (b)
	{
		[b hide];
	}
}

+(bool)hasBaloonInView:(BaseElement*)v
{
	return ([v getChildWithName:@"baloon"] != nil);
}

-(void)draw
{
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);		
	
	[super preDraw];	
	[super postDraw];
}

-(void)onButtonPressed:(int)n
{	
	switch (n)
	{
		case BUTTON_CLOSE:			
			if (type == BALOON_SINGLE || type == BALOON_MULTIPLE_LAST)
			{
				[charImage playTimeline:HIDE_TIMELINE];
			}		
			
			if (type != BALOON_STATIC)
			{
				[baloonBack playTimeline:HIDE_TIMELINE];
			}
			break;
	}
}

-(void)timeline:(Timeline*)t reachedKeyFrame:(KeyFrame*)k withIndex:(int)i
{
}

-(void)timelineFinished:(Timeline*)t
{
	if ([delegate respondsToSelector:@selector(baloonClosed:)])
	{
		[delegate baloonClosed:self];
	}
	
	[self->parent removeChild:self];
}

-(void)hide
{
	[super hide];
	[self->parent removeChild:self];	
}

-(bool)onTouchDownX:(float)tx Y:(float)ty
{
	bool res = [super onTouchDownX:tx Y:ty];
	return (blocking) ? TRUE : res;
}

-(bool)onTouchUpX:(float)tx Y:(float)ty
{
	bool res = [super onTouchUpX:tx Y:ty];
	return (blocking) ? TRUE : res;
}

-(bool)onTouchMoveX:(float)tx Y:(float)ty
{
	bool res = [super onTouchMoveX:tx Y:ty];
	return (blocking) ? TRUE : res;
}

@end

@implementation BannerBaloon

+(void)showBaloonWithID:(int)bID Banner:(Texture2D*)banner URL:(NSString*)u Image:(Image*)im Blocking:(bool)bl Type:(int)tp inView:(BaseElement*)v Delegate:(id<BaloonDelegate>)dl
{
	BannerBaloon* activeBaloon = [[BannerBaloon allocAndAutorelease] init];
	activeBaloon->anchor = activeBaloon->parentAnchor = BOTTOM | HCENTER;
	[activeBaloon setName:@"baloon"];
	activeBaloon->width = SCREEN_WIDTH;
	activeBaloon->height = SCREEN_HEIGHT;
	
	activeBaloon->baloonID = bID;
	activeBaloon->blocking = bl;
	activeBaloon->type = tp;	
	activeBaloon->delegate = dl;	
	activeBaloon->charImage = im;
	
	activeBaloon->charImage->anchor = CENTER;
	activeBaloon->charImage->parentAnchor = CENTER;
	activeBaloon->charImage->y = 140.0;
	activeBaloon->charImage->x = 100.0;
	activeBaloon->charImage->rotation = -15.0;
	[activeBaloon addChild:activeBaloon->charImage];	
	
	activeBaloon->baloonBack = [Image createWithResID:IMG_BALOON];
	activeBaloon->baloonBack->anchor = activeBaloon->baloonBack->parentAnchor = BOTTOM | HCENTER;
	activeBaloon->baloonBack->x = -20.0;
	[activeBaloon addChild:activeBaloon->baloonBack];
	activeBaloon->url = [u retain];
	
	Image* t1 = [Image create:banner];
	Image* t2 = [Image create:banner];
	
	Button* bn = [[Button allocAndAutorelease] initWithUpElement:t1 DownElement:t2 andID:BUTTON_BANNER];
	bn->anchor = bn->parentAnchor = CENTER;
	bn.delegate = activeBaloon;
	[activeBaloon->baloonBack addChild:bn];		
	
	if (activeBaloon->type != BALOON_STATIC)
	{		
		Button* close = [MenuController createButtonWithImage:((activeBaloon->type == BALOON_SINGLE || activeBaloon->type == BALOON_MULTIPLE_LAST) ? 
															   IMG_BALOON_CLOSE : IMG_BALOON_NEXT_NEWS) ID:BUTTON_CLOSE Delegate:activeBaloon];
		close->anchor = close->parentAnchor = BOTTOM | HCENTER;
		close->y = -87.0;
		close->x = 75.0;
		[activeBaloon->baloonBack addChild:close];
	}
	
	[Baloon setBaloonAnimations:activeBaloon];
	
	ASSERT(v);
	[v addChild:activeBaloon];	
}

-(void)onButtonPressed:(int)n
{
	switch (n) 
	{
		case BUTTON_CLOSE:
			[super onButtonPressed:n];
			break;
			
		case BUTTON_BANNER:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
			break;
	}
}

-(void)dealloc
{
	[url release];
	[super dealloc];
}

@end
