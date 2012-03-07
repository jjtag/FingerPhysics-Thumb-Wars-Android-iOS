//
//  Application.h
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicationSettings.h"
#import "RootController.h"
#import "ResourceMgr.h"
#import "Accelerometer.h"
#import "SoundMgr.h"
#import "GLCanvas.h"
#import "AppUIViewController.h"
#import "Preferences.h"
	
// base application class
@interface Application : NSObject <UIApplicationDelegate> 
{
	// the only window object
	UIWindow* window;
}

// override these if needed
-(RootController*) createRootController;
-(ApplicationSettings*) createAppSettings;
-(ResourceMgr*) createResourceMgr;
-(Accelerometer*) createAccelerometer;
-(SoundMgr*) createSoundMgr;
-(GLCanvas*) createCanvas;
-(AppUIViewController*) createUIViewController;
-(Preferences*) createPreferences;

+(RootController*) sharedRootController;
+(ApplicationSettings*) sharedAppSettings;
+(ResourceMgr*) sharedResourceMgr;
+(Accelerometer*) sharedAccelerometer;
+(SoundMgr*) sharedSoundMgr;
+(GLCanvas*) sharedCanvas;
+(AppUIViewController*) sharedUIViewController;
+(Preferences*) sharedPreferences;

- (void)applicationDidFinishLaunching:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;
- (void)applicationSignificantTimeChange:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;


-(void)updateOrientation;
-(void)finalRelease;

@property (nonatomic, retain) UIWindow *window;

@end