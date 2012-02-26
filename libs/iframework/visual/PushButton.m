//
//  PushButton.m
//  barbie
//
//  Created by Mac on 18.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PushButton.h"
#import "Framework.h"

@implementation PushButtonGroup

-(void)notifyPressed:(int)n
{
	for (BaseElement* c in childs)
	{
		ASSERT([c isKindOfClass:[PushButton class]]);
		PushButton* b = (PushButton*)c;		
		if (b->buttonID != n)
		{
			[b setState:BUTTON_UP];
		}
	}
}

-(void)pushButton:(int)n
{
	for (BaseElement* c in childs)
	{
		ASSERT([c isKindOfClass:[PushButton class]]);
		PushButton* b = (PushButton*)c;		
		if (b->buttonID == n)
		{			
			[b setState:BUTTON_PUSHED];
			[self notifyPressed:n];
			break;
		}
	}
}

-(void)addChild:(BaseElement*)c withID:(int)i
{
	[super addChild:c withID:i];
	
	ASSERT([c isKindOfClass:[PushButton class]]);
	PushButton* b = (PushButton*)c;		
	b->group = self;
}

@end

@implementation PushButton

-(id)initWithID:(int)n
{
	if (self = [super initWithID:n])
	{		
		pushOnRelease = FALSE;
		canBeUnpushed = FALSE;
	}
	
	return self;
}

-(bool)onTouchDownX:(float)tx Y:(float)ty
{
	if (pushOnRelease)
	{
		return [super onTouchDownX:tx Y:ty];
	}
	
	if (state == BUTTON_UP || (state == BUTTON_PUSHED && canBeUnpushed))
	{
		if ([self isInTouchZoneX:tx Y:ty])
		{
			if (state == BUTTON_UP)
			{
				[group notifyPressed:buttonID];
				[self setState:BUTTON_PUSHED];
				[delegate onButtonPressed:buttonID];
			}
			else
			{
				[group notifyPressed:UNDEFINED];
				[self setState:BUTTON_UP];
				if ([delegate respondsToSelector:@selector(onButtonUnpushed:)])
				{
					[delegate onButtonUnpushed:buttonID];
				}				
			}
			return TRUE;
		}
	}
	
	return FALSE;	
}


-(bool)onTouchUpX:(float)tx Y:(float)ty
{
	if (!pushOnRelease) return FALSE;
	
	if (state == BUTTON_DOWN || (state == BUTTON_PUSHED && canBeUnpushed))
	{
		if (state == BUTTON_DOWN)
		{
			[self setState:BUTTON_UP];	
		}
		
		if ([self isInTouchZoneX:tx Y:ty])
		{		
			if (state == BUTTON_UP)
			{
				[group notifyPressed:buttonID];
				[self setState:BUTTON_PUSHED];
				[delegate onButtonPressed:buttonID];
			}
			else
			{
				[group notifyPressed:UNDEFINED];
				[self setState:BUTTON_UP];
				if ([delegate respondsToSelector:@selector(onButtonUnpushed)])
				{
					[delegate onButtonUnpushed:buttonID];
				}				
			}
			return TRUE;			
		}		
	}
	
	return FALSE;
}

-(void)setState:(int)s
{
	ASSERT(s == BUTTON_UP || s == BUTTON_DOWN || s == BUTTON_PUSHED);
	
	state = s;
	BaseElement* up = [self getChild:BUTTON_UP];
	BaseElement* down = [self getChild:BUTTON_DOWN];
	
	[up setEnabled:(s == BUTTON_UP)];
	[down setEnabled:(s == BUTTON_DOWN || s == BUTTON_PUSHED)];
}

@end
