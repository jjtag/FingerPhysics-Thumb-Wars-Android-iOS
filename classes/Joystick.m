//
//  Joystick.m
//  champions
//
//  Created by ikoryakin on 3/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Joystick.h"


@implementation Joystick

@synthesize delegate;

+(Joystick*)create:(Texture2D*)t maxOffsetX:(float)maxX maxOffsetY:(float)maxY
{
	return [[[Joystick alloc] initWithMaxOffsetX:maxX maxOffsetY:maxY andTexture:t] autorelease];
}

-(id)initWithMaxOffsetX:(float)maxX maxOffsetY:(float)maxY andTexture:(Texture2D*)t
{
	if(self = [super initWithTexture:t])
	{
		maxOffsetX = maxX;
		maxOffsetY = maxY;
	}
	return self;
}

// single touch handling, returnes TRUE if touch changed element, FALSE otherwise
-(bool)onTouchDownX:(float)tx Y:(float)ty
{
	if (pointInRect(tx, ty, drawX - touchLeftInc, drawY - touchTopInc, 
					 width + (touchLeftInc + touchRightInc), height + (touchTopInc + touchBottomInc)))
	{
		active = TRUE;
		[super onTouchDownX:tx Y:ty];
		startX = tx;
		startY = ty;
		return TRUE;
	}
	return FALSE;
}

-(bool)onTouchUpX:(float)tx Y:(float)ty
{
	if(!active)return FALSE;
	
	[super onTouchUpX:tx Y:ty];
	startX = 0;
	startY = 0;
	offsetX = 0;
	offsetY = 0;
	active = FALSE;
	if (delegate)
	{
		[delegate onJoyOffsetX:offsetX OffsetY:offsetY];	
		return TRUE;
	}
	return FALSE;
}

-(bool)onTouchMoveX:(float)tx Y:(float)ty
{
	if(!active)return FALSE;
	
	[super onTouchMoveX:tx Y:tx];
	offsetX = tx - startX;
	offsetY = ty - startY;
	offsetX = MAX(MIN(offsetX, maxOffsetX), -maxOffsetX);
	offsetY = MAX(MIN(offsetY, maxOffsetY), -maxOffsetY);
	if (delegate)
	{
		[delegate onJoyOffsetX:offsetX OffsetY:offsetY];	
		return TRUE;
	}
	return FALSE;
}

-(void)draw
{
	glTranslatef(offsetX, offsetY, 0);
	[super draw];
	glTranslatef(-offsetX, -offsetY, 0);
}
@end
