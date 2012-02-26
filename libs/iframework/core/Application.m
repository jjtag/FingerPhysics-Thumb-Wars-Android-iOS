//
//  Application.m
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Application.h"
#import "Framework.h"

RootController* root;	
ApplicationSettings* appSettings;
ResourceMgr* resourceMgr;
Accelerometer* accelerometer;
SoundMgr* soundMgr;
MovieMgr* movieMgr;
GLCanvas* canvas;
AppUIViewController* uiViewController;
Preferences* prefs;

@implementation Application

@synthesize window;

// override these singleton getters
+(ApplicationSettings*) sharedAppSettings
{
	return appSettings;
}

+(ResourceMgr*) sharedResourceMgr
{
	return resourceMgr;
}

+(RootController*) sharedRootController
{
	return root;
}

+(Accelerometer*) sharedAccelerometer
{
	return accelerometer;
}

+(SoundMgr*) sharedSoundMgr
{
	return soundMgr;
}

+(MovieMgr*) sharedMovieMgr
{
	return movieMgr;
}

+(GLCanvas*) sharedCanvas
{
	return canvas;
}

+(AppUIViewController*) sharedUIViewController
{
	return uiViewController;
}

+(Preferences*) sharedPreferences
{
	return prefs;
}

-(RootController*) createRootController
{
	ASSERT(!root);	
	return [[RootController alloc] initWithParent:nil];
}

-(ApplicationSettings*) createAppSettings
{
	ASSERT(!appSettings);
	return [[ApplicationSettings alloc] init];
}

-(ResourceMgr*) createResourceMgr
{
	ASSERT(!resourceMgr);
	return [[ResourceMgr alloc] init];
}

-(Accelerometer*) createAccelerometer
{
	ASSERT(!accelerometer);
	return [[Accelerometer alloc] init];	
}

-(SoundMgr*) createSoundMgr
{
	ASSERT(!soundMgr);
	return [[SoundMgr alloc] init];	
}

-(MovieMgr*) createMovieMgr
{
	ASSERT(!movieMgr);
	return [[MovieMgr alloc] init];	
}

-(GLCanvas*) createCanvas
{
	ASSERT(!canvas);
	return [[GLCanvas alloc] initWithFrame:window.frame];		
}

-(AppUIViewController*) createUIViewController
{
	ASSERT(!uiViewController);
	return [[AppUIViewController alloc] init];		
}

-(Preferences*) createPreferences
{
	ASSERT(!prefs);
	return [[Preferences alloc] init];	
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{		
	//TODO: implement this
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

	// application settings	
	appSettings = [self createAppSettings];

	if ([appSettings getBool:APP_SETTING_LOCALIZATION_ENABLED])
	{
		NSString* country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
		[appSettings set:APP_SETTING_LOCALE String:[country lowercaseString]];
	}
	
	application.statusBarHidden = [appSettings getBool:APP_SETTING_STATUSBAR_HIDDEN];		
	
	// init application window 
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[window setUserInteractionEnabled:[appSettings getBool:APP_SETTING_INTERACTION_ENABLED]];
	[window setMultipleTouchEnabled:[appSettings getBool:APP_SETTING_MULTITOUCH_ENABLED]];
	
	[window makeKeyAndVisible];

	// init global objects
	canvas = [self createCanvas];	
	uiViewController = [self createUIViewController];
	resourceMgr = [self createResourceMgr];
	root = [self createRootController];		
	accelerometer = [self createAccelerometer];	
	soundMgr = [self createSoundMgr];
	movieMgr = [self createMovieMgr];
	prefs = [self createPreferences];
	
	// add canvas to window, show it and start root controller
	[self updateOrientation];
	[uiViewController setView:canvas];	
	[window addSubview:uiViewController.view];
	canvas.touchDelegate = root;
	canvas.multipleTouchEnabled = [[Application sharedAppSettings] getBool:APP_SETTING_MULTITOUCH_ENABLED];		
	[canvas show];
	
	[root activate];	
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	if (![root isSuspended])
	{
		[root suspend];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	if ([root isSuspended])
	{
		[root resume];
	}
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self finalRelease];
}

-(void)updateOrientation
{
	int orientation = [[Application sharedAppSettings] getInt:APP_SETTING_ORIENTATION];
	
	switch (orientation)
	{
		case ORIENTATION_LANDSCAPE_RIGHT:
			SCREEN_WIDTH = 480.0;
			SCREEN_HEIGHT = 320.0;
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:NO];
			break;
		case ORIENTATION_LANDSCAPE_LEFT:
			SCREEN_WIDTH = 480.0;
			SCREEN_HEIGHT = 320.0;
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated:NO];
			break;			
		case ORIENTATION_PORTRAIT:
			SCREEN_WIDTH = 320.0;
			SCREEN_HEIGHT = 480.0;
			[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:NO];	
			break;			
			
		default:
			ASSERT(FALSE);
	}	
}

-(void)finalRelease
{
	[window release];
	
	[root release];

	[resourceMgr release];	
	[accelerometer release];
	[soundMgr release];
	[movieMgr release];
	[prefs release];	
}

@end
