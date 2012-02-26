//
//  GLToggleButton.m
//  template
//
//  Created by Mac on 04.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ToggleButton.h"
#import "Framework.h"

@implementation ToggleButton

@synthesize delegate;

-(id)initWithUpElement1:(BaseElement*)u1 DownElement1:(BaseElement*)d1 UpElement2:(BaseElement*)u2 DownElement2:(BaseElement*)d2
	 andID:(int)bid
{
	if (self = [super init])
	{
		buttonID = bid;
		
		b1 = [[Button allocAndAutorelease] initWithUpElement:u1 DownElement:d1 andID:TOGGLE_BUTTON_FACE1];
		b2 = [[Button allocAndAutorelease] initWithUpElement:u2 DownElement:d2 andID:TOGGLE_BUTTON_FACE2];
		b1->parentAnchor = b2->parentAnchor = TOP | LEFT;
		width = b1->width;
		height = b1->height;
		
		[self addChild:b1 withID:TOGGLE_BUTTON_FACE1];
		[self addChild:b2 withID:TOGGLE_BUTTON_FACE2];
		
		[b2 setEnabled:FALSE];
		b1.delegate = self;
		b2.delegate = self;
	}
	
	return self;
}

-(void)onButtonPressed:(int)n
{
	switch (n)
	{
		case TOGGLE_BUTTON_FACE1:
		case TOGGLE_BUTTON_FACE2:
			[self toggle];
			break;			
	}
	
	[delegate onButtonPressed:buttonID];
}

-(void)setTouchIncreaseLeft:(float)l Right:(float)r Top:(float)t Bottom:(float)b
{
	[b1 setTouchIncreaseLeft:l Right:r Top:t Bottom:b];
	[b2 setTouchIncreaseLeft:l Right:r Top:t Bottom:b];
}

-(void)toggle
{
	[b1 setEnabled:![b1 isEnabled]];
	[b2 setEnabled:![b2 isEnabled]];	
}

-(bool)on
{
	return [b2 isEnabled];
}

@end
