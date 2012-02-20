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
#import "FlurryAPI.h"

#ifdef TAPZILLA
#import "TapZillaCoupon.h"
#endif

@implementation ChampionsApp

// overrided
-(RootController*) createRootController
{
	ASSERT(!root);
	return [[ChampionsRootController alloc] initWithParent:nil];
}

-(ApplicationSettings*) createAppSettings
{
	ASSERT(!appSettings);
	return [[ChampionsApplicationSettings alloc] init];
}

-(ResourceMgr*) createResourceMgr
{
	ASSERT(!resourceMgr);
	return [[ChampionsResourceMgr alloc] init];
}

-(Preferences*) createPreferences
{
	ASSERT(!prefs);
	return [[ChampionsPreferences alloc] init];
}

-(SoundMgr*) createSoundMgr
{
	ASSERT(!soundMgr);
	return [[ChampionsSoundMgr alloc] init];
}

///////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[super applicationDidFinishLaunching:application];
#ifdef FREE
	[FlurryAPI startSession:@"3W2TQ1C1BBNN9ZK7XTCF"];
#else
	[FlurryAPI startSession:@"77219ZKM6V5FHXXG8U1E"];
#endif
#ifdef TAPZILLA
	[TapZillaCoupon sharedManager];
#endif
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
