//
//  StartupController.m
//  blockit
//
//  Created by Efim Voinov on 18.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoadingController.h"
#import "ChampionsResourceMgr.h"
#import "ChampionsRootController.h"
#import "LoadingView.h"
#import "Baloon.h"

@implementation LoadingController

-(id)initWithParent:(ViewController*)p
{	
	if (self = [super initWithParent:p])
	{	
		LoadingView* view = [[LoadingView allocAndAutorelease] initFullscreen];
		[self addView:view withID:0];

		Image* back = [Image create:[ChampionsResourceMgr getResource:IMG_LOADING_SCREEN_01]];
		[view addChild:back];
		
		LoadingView* view2 = [[LoadingView allocAndAutorelease] initFullscreen];
		[self addView:view2 withID:1];
		
		Image* back2 = [Image create:[ChampionsResourceMgr getResource:IMG_LOADING_SCREEN_02]];
		[view2 addChild:back2];
	}
	return self;
}

-(void)activate
{
	[super activate];
	int vID = UNDEFINED;
	ChampionsRootController* rc = (ChampionsRootController*)[Application sharedRootController];
	if(rc)
	{
		if([rc.selectedMap hasPrefix:@"1"])
		{
			vID = 0;
		}
		else
		{
			vID = 1;
		}
	}
	else
	{
		vID = RND_RANGE(0, 1);
	}
	[self showView:vID];
	
	int tutorialLevel = rc.user.tutorialLevel;
	[Baloon showBaloonWithID:0 Text:HINT_STR((tutorialLevel != UNDEFINED) ? RND_RANGE(STR_HINTS_REDNECK_HINT_01, STR_HINTS_REDNECK_HINT_02) : RND_RANGE(STR_HINTS_SERGEANT_HINT_01, STR_HINTS_SERGEANT_HINT_06)) 
					   Image:[Image createWithResID:IMG_PERSONAGES Quad:(tutorialLevel != UNDEFINED) ? IMG_PERSONAGES_dude01 : IMG_PERSONAGES_dude02] Blocking:FALSE Type:BALOON_STATIC inView:[self getView:vID] 
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
