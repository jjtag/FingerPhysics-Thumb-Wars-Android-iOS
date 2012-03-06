//
//  RootController.h
//  blockit
//
//  Created by Efim Voinov on 20.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "GLCanvas.h"
#import "Grabber.h"

// time in seconds of view transitions
#define TRANSITION_DEFAULT_DELAY 0.4

// view transitions
enum 
{
	TRANSITION_SLIDE_HORIZONTAL_RIGHT, 
	TRANSITION_SLIDE_HORIZONTAL_LEFT, 
	TRANSITION_SLIDE_VERTICAL, 
	TRANSITION_FADE_OUT_BLACK, 
	TRANSITION_FADE_OUT_WHITE, 
	TRANSITION_REVEAL,
	TRANSITIONS_COUNT
};

// the main application controller, which operates the main loop
@interface RootController : ViewController<TimerDelegate>
{	
@protected	
	// currently operated controller
	ViewController* currentController;

	// timer is used to invoke update repeatedly or to enter runloop (depends on the app settings)
	Timer* timer;
			
	int viewTransition;	
	CFAbsoluteTime transitionTime;
	View* previousView;
	TimeType transitionDelay;
	Texture2D* prevScreenImage;
	Texture2D* nextScreenImage;
	Grabber* screenGrabber;
	
	bool suspended;
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Debug ////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// used to display alert messages
	UIAlertView* systemAlert;
	int alertType;

	// TRUE if we are inside blocking alert run loop (used to display alerts when we can't catch exceptions)
	bool blockingAlertActive;		
}

@property (readonly) bool blockingAlertActive;
@property (assign) int viewTransition;
@property (assign) TimeType transitionDelay;

- (id)initWithParent:(ViewController*)p;

-(void)setViewTransition:(int)transition;
-(void)setViewTransitionDelay:(float)delay;

// root receives these notifications from all view controllers
-(void)onControllerActivated:(ViewController*)c;
-(void)onControllerDeactivated:(ViewController*)c;
-(void)onControllerPaused:(ViewController*)c;
-(void)onControllerUnpaused:(ViewController*)c;
-(void)onControllerViewShow:(View*)v;
-(void)onControllerViewHide:(View*)v;

-(void)setCurrentController:(ViewController*)c;
-(ViewController*)getCurrentController;

// suspend / resume
-(bool)isSuspended;
-(void)suspend;
-(void)resume;

// shows system alert
-(void)showAlertWithTitle:(NSString*)title AndMessage:(NSString*)message OfType:(int)type;
-(void)showBlockingAlertWithTitle:(NSString*)title AndMessage:(NSString*)message OfType:(int)type;

-(Grabber*)getScreenGrabber;

// main application loop
-(void)runLoop;
// updates current controller and draws current view
-(void)operateCurrentMVC;
// draw transition of views
-(void)drawViewTransition;
-(void)applyLandscape;
#ifndef NO_ALERTS
// terminate application
-(void)terminateApp:(int)code;
#endif

@end
