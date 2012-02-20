//
//  StartupController.m
//  blockit
//
//  Created by Efim Voinov on 18.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoadingController.h"
#import "ChampionsResourceMgr.h"
#import "LoadingView.h"
#import "Baloon.h"

@implementation LoadingController

- (id)initWithParent:(ViewController*)p;
{	
	if (self = [super initWithParent:p]) 
	{	
		LoadingView* view = [[LoadingView allocAndAutorelease] initFullscreen];
		[self addView:view withID:0];

		Image* back = [Image create:[ChampionsResourceMgr getResource:IMG_LOADING_SCREEN_01+RND_0_1]];
		[view addChild:back];
	}
	return self;
}

-(void)activate
{
	[super activate];
	[self showView:0];
	[Baloon showBaloonWithID:0 Text:[ChampionsResourceMgr getString:RND_RANGE(STR_HINTS_SERGEANT_HINT_01, STR_HINTS_SERGEANT_HINT_07)] 
					   Image:[Image createWithResID:IMG_PERSONAGES Quad:IMG_PERSONAGES_dude02] Blocking:FALSE Type:BALOON_STATIC inView:[self getView:0] 
					   Delegate:nil];	
}

-(void)resourceLoaded:(int)res
{
}

-(void)allResourcesLoaded
{
	[super deactivate];
}

@end
