//
//  ViewController.m
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Debug.h"
#import "Application.h"

#define DEFAULT_VIEWS_CAPACITY 10
#define DEFAULT_CHILDS_CAPACITY 10

@interface ViewController (Private)

// used for debugging
-(bool) checkNoChildsActive;
-(void) hideActiveView;
// convert touch events for landscape mode
-(Vector)convertTouchForLandscape:(Vector)t;

@end

@implementation ViewController

@synthesize controllerState;
@synthesize activeViewID;
@synthesize activeChildID;
@synthesize frameRate;
@synthesize idealDelta;
@synthesize lastTime;

+(ViewController*)createWithParent:(ViewController*)p
{
	return [[[[self class] alloc] initWithParent:p] autorelease];
}

- (id)init
{
	// we should not create viewcontroller without setting the root window and parent
	ASSERT(FALSE);
	return nil;
}

- (id)initWithParent:(ViewController*)p;
{
	if (self = [super init]) 
	{
		controllerState = CONTROLLER_DEACTIVE;
		views = [[DynamicArray alloc] initWithCapacity:DEFAULT_VIEWS_CAPACITY andOverReallocValue:DEFAULT_VIEWS_CAPACITY];
		childs = [[DynamicArray alloc] initWithCapacity:DEFAULT_CHILDS_CAPACITY andOverReallocValue:DEFAULT_CHILDS_CAPACITY];
		activeViewID = UNDEFINED;
		activeChildID = UNDEFINED;
		pausedViewID = UNDEFINED;
		parent = p;
		lastTime = UNDEFINED;
	}
	return self;
}

- (void)activate
{
	ASSERT(controllerState == CONTROLLER_DEACTIVE);
	controllerState = CONTROLLER_ACTIVE;
	[[Application sharedRootController] onControllerActivated:self];
}

- (void)deactivate
{
	ASSERT(controllerState == CONTROLLER_PAUSED || controllerState == CONTROLLER_ACTIVE);
	controllerState = CONTROLLER_DEACTIVE;
	
	if (activeViewID != UNDEFINED)
	{
		[self hideActiveView];
	}
	
	// notify parent controller
	ASSERT_MSG(([parent activeChild] == self || parent == nil), @"Trying to deactivate child which is not marked as active by it's parent"); 
	[[Application sharedRootController] onControllerDeactivated:self];	
	[parent onChildDeactivated:parent.activeChildID];	
}

- (void)pause
{
	ASSERT(controllerState == CONTROLLER_ACTIVE);
	controllerState = CONTROLLER_PAUSED;
	[[Application sharedRootController] onControllerPaused:self];
	
	if (activeViewID != UNDEFINED)
	{
		pausedViewID = activeViewID;
		[self hideActiveView];
	}
}

- (void)unpause
{
	ASSERT(controllerState == CONTROLLER_PAUSED);
	controllerState = CONTROLLER_ACTIVE;
	ASSERT([self checkNoChildsActive]);	
	
	if (activeChildID != UNDEFINED)
	{
		activeChildID = UNDEFINED;
	}
	
	[[Application sharedRootController] onControllerUnpaused:self];
	
	if (pausedViewID != UNDEFINED)
	{
		[self showView:pausedViewID];
	}
}

- (void)update
{
	if (activeViewID == UNDEFINED) return;
	
	View* v = (View*)[self activeView];
	[v update:delta];
}

- (void)calculateTimeDelta
{
	CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
	if (lastTime != UNDEFINED)
	{
		delta = time - lastTime;		
	}
	else
	{
		delta = 0;
	}
	lastTime = time;
}

// should be run each update
-(void) calculateFPS
{
	frames++;
	accumDt += delta;
	
	if ( accumDt > 0.1)  {
		frameRate = frames / accumDt;
		frames = 0;
		accumDt = 0;
	}	
}

//////////////////////////////////////////////////////////////////////////////////

- (void)addView:(View*)v withID:(int)n;
{
	ASSERT([views objectAtIndex:n] == nil);
	[views setObject:v At:n];
}

- (void)deleteView:(int)n
{
	ASSERT([views objectAtIndex:n] != nil);
	[views setObject:nil At:n];
}

- (void)hideActiveView
{
	View* prevV = [views objectAtIndex:activeViewID];
	[[Application sharedRootController] onControllerViewHide:prevV];
	[prevV hide];
	activeViewID = UNDEFINED;
}

- (void)showView:(int)n
{
	ASSERT(controllerState == CONTROLLER_ACTIVE);
	ASSERT([views objectAtIndex:n] != nil);

	// check that we don't activate already active view
	if (activeViewID != UNDEFINED)
	{
		ASSERT([views objectAtIndex:n] != [views objectAtIndex:activeViewID]); 
		[self hideActiveView];
	}	
	
	activeViewID = n;
	View* v = [views objectAtIndex:n];
	[[Application sharedRootController] onControllerViewShow:v];
	[v show];
}

- (View*)activeView
{
	ASSERT(activeViewID != UNDEFINED);
	ASSERT([views objectAtIndex:activeViewID] != nil);
	View* v = [views objectAtIndex:activeViewID];
	ASSERT(v);
	return v;
}

- (View*)getView:(int)n
{
	return [views objectAtIndex:n];	
}

///////////////////////////////////////////////////////////////////////////////////////

- (void)addChild:(ViewController*)c withID:(int)n;
{
	ASSERT([childs objectAtIndex:n] == nil);
	[childs setObject:c At:n];
}

- (void)deleteChild:(int)n
{
	ASSERT([childs objectAtIndex:n] != nil);
	[childs setObject:nil At:n];	
}

- (void)deactivateActiveChild
{
	ViewController* prevC = [childs objectAtIndex:activeChildID];
	[prevC deactivate];
	activeChildID = UNDEFINED;
}

- (void)activateChild:(int)n
{
	ASSERT(controllerState == CONTROLLER_ACTIVE);
	ASSERT([childs objectAtIndex:n] != nil);

	// check that we don't activate already active child
	if (activeChildID != UNDEFINED)
	{
		ASSERT([childs objectAtIndex:n] != [childs objectAtIndex:activeChildID]); 
		[self deactivateActiveChild];
	}	
	
	[self pause];
	
	activeChildID = n;
	ViewController* c = [childs objectAtIndex:n];
	[c activate];
}

- (void)onChildDeactivated:(int)n;
{
	[self unpause];
}

- (ViewController*)activeChild
{
	ASSERT(activeChildID != UNDEFINED);
	ASSERT([childs objectAtIndex:activeChildID] != nil);
	ViewController* c = [childs objectAtIndex:activeChildID];
	ASSERT(c);
	return c;
}			
				
- (ViewController*)getChild:(int)n
{
	return [childs objectAtIndex:n];
}

// used for debugging
- (bool) checkNoChildsActive
{
	for (ViewController* c in childs)
	{
		if (c.controllerState != CONTROLLER_DEACTIVE)
		{
			return FALSE;
		}
	}
	
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////////

-(Vector)convertTouchForLandscape:(Vector)t
{
	Vector p = t;
	int orientation = [[Application sharedAppSettings] getInt:APP_SETTING_ORIENTATION];

	if (orientation != ORIENTATION_PORTRAIT)
	{
		if (orientation == ORIENTATION_LANDSCAPE_LEFT)
		{
			p.x = SCREEN_WIDTH - t.y;
			p.y = t.x;			
		}
		else
		{
			p.x = t.y;
			p.y = SCREEN_HEIGHT - t.x;			
		}
	}
	
	return p;
}

// let views handle events
- (bool) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	if (activeViewID == UNDEFINED) return FALSE;
	
	View* v = (View*)[self activeView];
	ASSERT(v);
	int numOfTouch = -1;
	for (UITouch *touch in touches)
	{
		numOfTouch++;
		if (numOfTouch > 1) break;
		CGPoint touchLocation = [touch locationInView:[Application sharedCanvas]];
		Vector tap = [self convertTouchForLandscape:vect(touchLocation.x, touchLocation.y)];
		
		return [v onTouchDownX:tap.x Y:tap.y];
	}
	
	return FALSE;
}

- (bool) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (activeViewID == UNDEFINED) return FALSE;
	
	View* v = (View*)[self activeView];
	ASSERT(v);
	int numOfTouch = -1;
	for (UITouch *touch in touches)
	{
		numOfTouch++;
		if (numOfTouch > 1) break;
		CGPoint touchLocation = [touch locationInView:[Application sharedCanvas]];
		Vector tap = [self convertTouchForLandscape:vect(touchLocation.x, touchLocation.y)];
		
		return [v onTouchUpX:tap.x Y:tap.y];
	}
	
	return FALSE;
}

- (bool) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	if (activeViewID == UNDEFINED) return FALSE;
	
	View* v = (View*)[self activeView];
	ASSERT(v);
	int numOfTouch = -1;
	for (UITouch *touch in touches)
	{
		numOfTouch++;
		if (numOfTouch > 1) break;
		CGPoint touchLocation = [touch locationInView:[Application sharedCanvas]];
		Vector tap = [self convertTouchForLandscape:vect(touchLocation.x, touchLocation.y)];
		
		return [v onTouchMoveX:tap.x Y:tap.y];
	}
	
	return FALSE;
}

- (bool)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc 
{
	[views release];
	[childs release];
    [super dealloc];
}

@end
