//
//  GLButton.m
//  blockit
//
//  Created by Efim Voinov on 27.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AlternateButton.h"
#import "Framework.h"

@implementation AlternateButton

@synthesize delegate;

+(AlternateButton*)createWithTextureUp:(Texture2D*)up Down:(Texture2D*)down ID:(int)bID
{
	Image* gUp = [Image create:up];
	Image* gDown = [Image create:down];
	
	return [[[AlternateButton alloc] initWithUpElement:gUp DownElement:gDown andID:bID] autorelease];
}

-(id)initWithID:(int)n
{
	if (self = [super init])
	{		
		buttonID = n;
		state = ALT_BUTTON_UP;
		
		touchLeftInc = 0.0;
		touchRightInc = 0.0;
		touchTopInc = 0.0;
		touchBottomInc = 0.0;
		
		forcedTouchZone = MakeRectangle(UNDEFINED, UNDEFINED, UNDEFINED, UNDEFINED);
	}
	
	return self;
}

-(id)initWithUpElement:(BaseElement*)up DownElement:(BaseElement*)down andID:(int)n;
{
	if (self = [self initWithID:n])
	{				
		up->parentAnchor = down->parentAnchor = TOP | LEFT;
		[self addChild:up withID:ALT_BUTTON_UP];
		[self addChild:down withID:ALT_BUTTON_DOWN];
		[self setState:ALT_BUTTON_UP];
	}
	
	return self;
}

-(void)forceTouchRect:(Rectangle)r
{
	forcedTouchZone = r;
}

-(void)setTouchIncreaseLeft:(float)l Right:(float)r Top:(float)t Bottom:(float)b;
{
	touchLeftInc = l;
	touchRightInc = r;
	touchTopInc = t;
	touchBottomInc = b;
}

-(void)setState:(int)s;
{
	ASSERT(s == ALT_BUTTON_UP || s == ALT_BUTTON_DOWN);
	
	state = s;
	BaseElement* up = [self getChild:ALT_BUTTON_UP];
	BaseElement* down = [self getChild:ALT_BUTTON_DOWN];
	
	[up setEnabled:(s == ALT_BUTTON_UP)];
	[down setEnabled:(s == ALT_BUTTON_DOWN)];
}

-(bool)isInTouchZoneX:(float)tx Y:(float)ty
{
	if (forcedTouchZone.w != UNDEFINED)
	{
		return pointInRect(tx, ty, drawX + forcedTouchZone.x, drawY + forcedTouchZone.y, forcedTouchZone.w, forcedTouchZone.h);
	}
	else
	{
		return pointInRect(tx, ty, drawX - touchLeftInc, drawY - touchTopInc, 
						   width + (touchLeftInc + touchRightInc), height + (touchTopInc + touchBottomInc));
	}
}

-(bool)onTouchDownX:(float)tx Y:(float)ty
{
	[super onTouchDownX:tx Y:ty];
	
	if (state == ALT_BUTTON_UP)
	{
		if ([self isInTouchZoneX:tx Y:ty])
		{
			[self setState:ALT_BUTTON_DOWN];
			return TRUE;
		}
	}
	
	return FALSE;	
}

-(bool)onTouchUpX:(float)tx Y:(float)ty
{
	[super onTouchUpX:tx Y:ty];
	
	if (state == ALT_BUTTON_DOWN)
	{
		[self setState:ALT_BUTTON_UP];	
		
		if ([self isInTouchZoneX:tx Y:ty])
		{		
			if (delegate)
			{
				[delegate onAlternateButtonPressed:self andId:buttonID];
			}
			return TRUE;			
		}		
	}
	
	return FALSE;
}

-(bool)onTouchMoveX:(float)tx Y:(float)ty
{
	[super onTouchMoveX:tx Y:ty];
	
	if (state == ALT_BUTTON_DOWN)
	{
		if (![self isInTouchZoneX:tx Y:ty])
		{
			[self setState:ALT_BUTTON_UP];
			return TRUE;			
		}		
	}
	
	return FALSE;	
}

-(void)addChild:(BaseElement*)c withID:(int)i
{
	ASSERT([childs count] <= 2);
	[super addChild:c withID:i];	
	
	c->parentAnchor = TOP | LEFT;
	
	if (i == ALT_BUTTON_DOWN)
	{
		width = c->width;
		height = c->height;
		[self setState:ALT_BUTTON_UP];	
	}
}

+(BaseElement*)createFromXML:(XMLNode*)xml
{
	XML_ASSERT_ATTR(@"buttonID", xml);
	int bid = [xml intAttr:@"buttonID"];
	AlternateButton* element = [[AlternateButton allocAndAutorelease] initWithID:bid];
	
	return element;
}

@end
