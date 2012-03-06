//
//  blockitAppDelegate.m
//  blockit
//
//  Created by reaxion on 05.03.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import "Framework.h"
#import "ChampionsApp.h"
#import "ChampionsRootController.h"
#import "ChampionsApplicationSettings.h"
#import "ChampionsResourceMgr.h"
#import "ChampionsSoundMgr.h"
#import "ChampionsPreferences.h"

@implementation ChampionsApp

// overrided
-(RootController*) createRootController
{
//	ASSERT(!root);
    ASSERT(![Application sharedRootController]);
	return [[ChampionsRootController alloc] initWithParent:nil];
}

-(ApplicationSettings*) createAppSettings
{
//	ASSERT(!appSettings);
    ASSERT(![Application sharedAppSettings]);
	return [[ChampionsApplicationSettings alloc] init];
}

-(ResourceMgr*) createResourceMgr
{
//	ASSERT(!resourceMgr);
    ASSERT(![Application sharedResourceMgr]);
	return [[ChampionsResourceMgr alloc] init];
}

-(Preferences*) createPreferences
{
//	ASSERT(!prefs);
    ASSERT(![Application sharedPreferences]);
	return [[ChampionsPreferences alloc] init];
}

-(SoundMgr*) createSoundMgr
{
//	ASSERT(!soundMgr);
    ASSERT(![Application sharedSoundMgr]);
	return [[ChampionsSoundMgr alloc] init];
}

///////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[super applicationDidFinishLaunching:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[Application sharedSoundMgr] stopAllSounds];
	[[Application sharedPreferences] savePreferences];
	[super applicationWillTerminate:application];	
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
	[super applicationDidReceiveMemoryWarning:application];		
	LOG(@"Low memory warning");
}

//- (void)applicationWillResignActive:(UIApplication *)application
//{
//	[super applicationWillResignActive:application];
//}

- (void)dealloc
{	
	[super dealloc];
}

@end
