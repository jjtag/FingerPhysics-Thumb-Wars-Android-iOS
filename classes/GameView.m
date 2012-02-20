//
//  GameView.m
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameView.h"
#import "ChampionsResourceMgr.h"
#import "Framework.h"

@implementation GameView

- (id)initFullscreen
{
	if (!(self = [super initFullscreen])) 
	{
		return nil;
	}
	
	return self;
}

-(void)show
{
	[[Application sharedAccelerometer] startAccelerometerWithFrequency:40 useFilter:TRUE useHighPassFilter: FALSE];	
	[super show];
}

-(void)hide
{
	[[Application sharedAccelerometer] stopAccelerometer];
	[super hide];
}

-(void)draw
{
	int childsCount = [self childsCount];
	
	for (int i = 0; i < childsCount; i++)
	{
		BaseElement* c = [self getChild:i];
		
		if (!c || !c->visible) continue;
		
		switch (i)
		{
			case VIEW_ELEMENT_WIN_MENU:
			{
//				glDisable(GL_TEXTURE_2D);
				glEnable(GL_BLEND);		
				glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
//				drawSolidRectWOBorder(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT, MakeRGBA(0.1, 0.1, 0.1, 0.5));
				glColor4f(1.0, 1.0, 1.0, 1.0);
				glEnable(GL_TEXTURE_2D);
				break;
			}				
			case VIEW_ELEMENT_PAUSE_MENU:
			case VIEW_ELEMENT_OPTIONS:
			case VIEW_ELEMENT_LOSE_MENU:
			{
				glDisable(GL_TEXTURE_2D);
				glEnable(GL_BLEND);		
				glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
				drawSolidRectWOBorder(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT, MakeRGBA(0.1, 0.1, 0.1, 0.5));
				glColor4f(1.0, 1.0, 1.0, 1.0);
				glEnable(GL_TEXTURE_2D);
				break;
			}
			case VIEW_ELEMENT_PAUSE_BUTTON:
			{
				glEnable(GL_TEXTURE_2D);
				glEnable(GL_BLEND);		
				glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
				break;
			}
		}
		
		[c draw];
	}
}

-(void)dealloc
{
	[super dealloc];
}

@end
