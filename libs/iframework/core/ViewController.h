//
//  ViewController.h
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "View.h"
#import "DynamicArray.h"
#import "Timer.h"
#import "FrameworkTypes.h"
#import "GLCanvas.h"

// base hierarchial view controller class

// controller phylosophy:
// - there's a root controller which is notified about every controller state change
// - only one controller runs (invokes 'update') at a time
// - controller can control several views (or none)
// - controller can have childs, when controller's child is active, controller itself is paused
// - child controller notifies parent after deactivation

enum { CONTROLLER_DEACTIVE = 0, CONTROLLER_ACTIVE = 1, CONTROLLER_PAUSED = 2 };

@interface ViewController : NSObject <TouchDelegate> 
{
 @protected
	int controllerState;

	int activeViewID;
	DynamicArray* views;
	
	// UNDEFINED if no child controllers active
	int activeChildID;
	DynamicArray* childs;
	ViewController* parent;
	
	int pausedViewID;
	//////////////////////////////////////////////////////////
	
	// time delta between last updates
	TimeType delta;
	// what time delta is supposed to be (this is a timer update interval)
	TimeType idealDelta;
	// last update time
	CFAbsoluteTime lastTime;
	// used to calculate FPS
	int frames;
	TimeType accumDt;
	TimeType frameRate;		
}

@property (readonly) int controllerState;
@property (readonly) int activeViewID;
@property (readonly) int activeChildID;

@property (readonly) TimeType frameRate;
@property (assign) TimeType idealDelta;
@property (readonly) CFAbsoluteTime lastTime;

+(ViewController*)createWithParent:(ViewController*)p;

// controller states handling
- (id)initWithParent:(ViewController*)p;
- (void)activate;
- (void)deactivate;
- (void)pause;
- (void)unpause;
- (void)update;

// views handling
- (void)addView:(View*)v withID:(int)n;
- (void)deleteView:(int)n;
- (void)showView:(int)n;
- (View*)activeView;
- (View*)getView:(int)n;

// childs handling
- (void)addChild:(ViewController*)c withID:(int)n;
- (void)deleteChild:(int)n;
- (void)activateChild:(int)n;
- (ViewController*)activeChild;
- (ViewController*)getChild:(int)n;

// sent to parent when child deactivates
- (void)onChildDeactivated:(int)n;

// triggered by root
-(void)calculateTimeDelta;
-(void)calculateFPS;

@end
