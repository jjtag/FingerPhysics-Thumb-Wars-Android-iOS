//
//  RootController.m
//  blockit
//
//  Created by Efim Voinov on 20.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Application.h"
#import "RootController.h"
#import "Debug.h"

@implementation RootController

@synthesize blockingAlertActive;
@synthesize viewTransition;
@synthesize transitionDelay;

- (id)initWithParent:(ViewController*)p;
{
	if (self = [super initWithParent:p])
	{		
		viewTransition = UNDEFINED;
		transitionTime = UNDEFINED;
		previousView = nil;
		transitionDelay = TRANSITION_DEFAULT_DELAY;
		
		screenGrabber = [[Grabber alloc] init];
		prevScreenImage = nil;
		nextScreenImage = nil;
		
		timer = [[Timer alloc] init];

		if ([[Application sharedAppSettings] getBool:APP_SETTING_MAIN_LOOP_TIMERED])
		{
			// used to continiously invoke update
			// this mode doesn't support global exception alerts 
			TimeType fps = (TimeType)[[Application sharedAppSettings] getInt:APP_SETTING_FPS];
			[timer setTimerInterval:1.0 / fps];
			timer.target = self;
			timer.selector = @selector(operateCurrentMVC);	
		}
		else
		{
			// used to invoke run loop once, setting fps is not supported in this mode
			// this mode supports global exception alerts but has problems with standard UI controls
			[timer setTimerInterval:0];
			timer.target = self;
			timer.selector = @selector(runLoop);
		}
	}
	return self;
}
 
-(void)operateCurrentMVC
{		
	@try
	{	
		//START_BENCHMARK(@"update", 1, FALSE);

		if (suspended)
		{
			return;
		}
		
		ASSERT(currentController);

		// pass control to the active controller
		[currentController calculateTimeDelta]; 

		[currentController update];	
		
		// draw active view
		if (currentController.activeViewID != UNDEFINED)
		{
			glPushMatrix();
			[self applyLandscape];
			
			if (transitionTime == UNDEFINED)
			{
				[[currentController activeView] draw];
			}
			else
			{
				[self drawViewTransition];
				
				if (currentController.lastTime > transitionTime)
				{
					transitionTime = UNDEFINED;
				}
			}
			
			// draw fps meter
			if ([[Application sharedAppSettings] getBool:APP_SETTING_FPS_METER_ENABLED])
			{
				[currentController calculateFPS];
				[[Application sharedCanvas] drawFPS:currentController.frameRate];			
			}

			// show render buffer
			[[Application sharedCanvas] swapBuffers];		
			glPopMatrix();
				
		}
		//END_BENCHMARK;				
	}
	@catch (NSException* e) 
	{
		LOG_AND_SHOW_EXCEPTION(e);
	}			
}

-(void)applyLandscape
{
	int orientation = [[Application sharedAppSettings] getInt:APP_SETTING_ORIENTATION];

	if (orientation != ORIENTATION_PORTRAIT) 
	{
		glTranslatef(160, 240, 0);
		
		if (orientation == ORIENTATION_LANDSCAPE_LEFT)
		{
			glRotatef(-90, 0, 0, 1);
			glTranslatef(-240, -160, 0);
		}		
		else
		{
			// rotate left
			glRotatef(90, 0, 0, 1);
			glTranslatef(-240, -160, 0);
		}
	}
}

-(void)setViewTransition:(int)transition
{
	ASSERT(transition == UNDEFINED || (transition >= 0 && transition < TRANSITIONS_COUNT));
	viewTransition = transition;
	
	if (viewTransition != UNDEFINED)
	{
		if (!prevScreenImage)
		{
			ASSERT(!nextScreenImage);
			Texture2DPixelFormat format = kTexture2DPixelFormat_RGB565;
			const int kTextureSize = 512;
			CGSize win = CGSizeMake(320.0, 480.0);
			
			void* data = malloc((int)(kTextureSize * kTextureSize * 4));
			memset(data, 0, (int)(kTextureSize * kTextureSize * 4));						
			prevScreenImage = [[Texture2D alloc] initWithData:data pixelFormat:format pixelsWide:kTextureSize pixelsHigh:kTextureSize contentSize:win];
			free(data);			
			
			data = malloc((int)(kTextureSize * kTextureSize * 4));
			memset(data, 0, (int)(kTextureSize * kTextureSize * 4));						
			nextScreenImage = [[Texture2D alloc] initWithData:data pixelFormat:format pixelsWide:kTextureSize pixelsHigh:kTextureSize contentSize:win];
			free(data);			
		}
	}
	else
	{
		if (prevScreenImage)
		{
			ASSERT(nextScreenImage);			
			[prevScreenImage release];
			prevScreenImage = nil;
			[nextScreenImage release];
			nextScreenImage = nil;
		}
	}
}

-(void)setViewTransitionDelay:(float)delay
{
	transitionDelay = delay;
}

- (void)drawViewTransition
{
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glLoadIdentity();

	switch (viewTransition) 
	{
		case TRANSITION_SLIDE_HORIZONTAL_RIGHT:
		{
			float offset = MIN(320.0, 320.0 * (transitionDelay - (transitionTime - currentController.lastTime)) / transitionDelay);		
			drawGrabbedImage(prevScreenImage, -offset, 0);
			drawGrabbedImage(nextScreenImage, 320.0 - offset, 0);						
			break;
		}
			
		case TRANSITION_SLIDE_HORIZONTAL_LEFT:
		{
			float offset = MIN(320.0, 320.0 * (transitionDelay - (transitionTime - currentController.lastTime)) / transitionDelay);
			drawGrabbedImage(prevScreenImage, offset, 0);
			drawGrabbedImage(nextScreenImage, -320.0 + offset, 0);						
			break;			
		}

		//TODO: implement
		case TRANSITION_SLIDE_VERTICAL:
		{
			ASSERT(FALSE);
			break;						
		}
						
		case TRANSITION_FADE_OUT_BLACK:
		case TRANSITION_FADE_OUT_WHITE:
		{			
			float offset = MIN(1.0, (transitionDelay - (transitionTime - currentController.lastTime)) / transitionDelay); 
			if (offset < 0.5)
			{
				RGBAColor color = (viewTransition == TRANSITION_FADE_OUT_BLACK) ? MakeRGBA(0.0, 0.0, 0.0, offset * 2.0) : MakeRGBA(1.0, 1.0, 1.0, offset * 2.0);
				drawGrabbedImage(prevScreenImage, 0, 0);				
				glEnable(GL_BLEND);			
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);		
				drawSolidRectWOBorder(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT, color);
				glDisable(GL_BLEND);
			}
			else
			{
				RGBAColor color = (viewTransition == TRANSITION_FADE_OUT_BLACK) ? MakeRGBA(0.0, 0.0, 0.0, 2.0 - offset * 2.0) : MakeRGBA(1.0, 1.0, 1.0, 2.0 - offset * 2.0);
				drawGrabbedImage(nextScreenImage, 0, 0);		
				glEnable(GL_BLEND);			
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);		
				drawSolidRectWOBorder(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT, color);				
				glDisable(GL_BLEND);				
			}
			break;			
		}
			
		case TRANSITION_REVEAL:
		{
			float offset = MIN(1.0, (transitionDelay - (transitionTime - currentController.lastTime)) / transitionDelay);			
			glColor4f(1.0, 1.0, 1.0, 1.0 - offset);
			drawGrabbedImage(prevScreenImage, 0, 0);
			glColor4f(1.0, 1.0, 1.0, offset);
			drawGrabbedImage(nextScreenImage, 0, 0);				
		}
			break;
	}
	
	[self applyLandscape];
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);	
}

- (void)activate
{
	[super activate];
	[timer startTimer];	
}

// main application run loop in case of not timered loop
-(void)runLoop
{
	// we don't need timer
	[timer stopTimer];
	
	while (TRUE)
	{
		@try
		{			
			// handle events
			while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);	
			[self operateCurrentMVC];
			while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);			
		}
		@catch (NSException* e) 
		{
			LOG_AND_SHOW_EXCEPTION(e);
		}			
	}
}

-(Grabber*)getScreenGrabber
{
	return screenGrabber;
}

-(void)onControllerActivated:(ViewController*)c
{
	[self setCurrentController:c];
}

-(void)onControllerDeactivated:(ViewController*)c
{
	[self setCurrentController:nil];	
}

-(void)onControllerPaused:(ViewController*)c
{
	[self setCurrentController:nil];	
}

-(void)onControllerUnpaused:(ViewController*)c
{
	[self setCurrentController:c];	
}

-(void)onControllerViewShow:(View*)v
{
	if (viewTransition != UNDEFINED && previousView != nil)
	{
		[currentController calculateTimeDelta];
		transitionTime = currentController.lastTime + transitionDelay;

		[self applyLandscape];
		[screenGrabber grab:nextScreenImage];				
		[screenGrabber beforeRender:nextScreenImage];
		[[currentController activeView] draw];
		[screenGrabber afterRender:nextScreenImage];  
		glLoadIdentity();
	}
}

-(void)onControllerViewHide:(View*)v
{
	previousView = v;
	if (viewTransition != UNDEFINED && previousView != nil)
	{
		[self applyLandscape];
		[screenGrabber grab:prevScreenImage];		
		[screenGrabber beforeRender:prevScreenImage];
		[previousView draw];
		[screenGrabber afterRender:prevScreenImage];				
		glLoadIdentity();		
	}
}

-(bool)isSuspended
{
	return suspended;
}

-(void)suspend
{
	ASSERT(!suspended);
	suspended = TRUE;
}

-(void)resume
{
	ASSERT(suspended);
	suspended = FALSE;	
}


// pass events to current controller
- (bool)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	@try
	{	
		return [currentController touchesBegan:touches withEvent:event];
	}
	@catch (NSException* e) 
	{
		LOG_AND_SHOW_EXCEPTION(e);
	}		
	
	return FALSE;
}
- (bool)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	@try
	{
		return [currentController touchesMoved:touches withEvent:event];
	}
	@catch (NSException* e) 
	{
		LOG_AND_SHOW_EXCEPTION(e);
	}	
	return FALSE;	
}
- (bool)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	@try
	{
		return[currentController touchesEnded:touches withEvent:event];
	}
	@catch (NSException* e) 
	{
		LOG_AND_SHOW_EXCEPTION(e);
	}	
	return FALSE;	
}
- (bool)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	@try
	{
		return [currentController touchesCancelled:touches withEvent:event];
	}
	@catch (NSException* e) 
	{
		LOG_AND_SHOW_EXCEPTION(e);
	}	
	return FALSE;	
}

// show system alert dialog
-(void)showAlertWithTitle:(NSString*)title AndMessage:(NSString*)message OfType:(int)type
{
#ifndef NO_ALERTS
	[systemAlert release];
	alertType = type;
	switch (alertType) 
	{
		case ALERT_TYPE_ERROR:
			systemAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ignore" otherButtonTitles:
#if defined(DEBUG) && TARGET_IPHONE_SIMULATOR
						   @"Debug"
#else
						   @"Exit"
#endif
						   , nil];
			break;
		case ALERT_TYPE_INFO:
			systemAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok"otherButtonTitles:nil];			
			break;
	}
	systemAlert.exclusiveTouch = YES;
	systemAlert.opaque = NO;
	[systemAlert show];	
#endif
}

// UIAlertView delegate protocol method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#ifndef NO_ALERTS	
	switch (alertType) 
	{
		case ALERT_TYPE_ERROR:
			// return to run loop;
			switch (buttonIndex)
			{
				// Ignore
				case 0:
					blockingAlertActive = FALSE;
					break;
#if defined(DEBUG) && TARGET_IPHONE_SIMULATOR
				// Debug
				case 1:
					DebugBreak();
					break;
#else					
				// Exit
				case 1:
					[self terminateApp:HANDLED_EXCEPTION_EXIT_CODE];
					break;
#endif
			}
			break;
			
		case ALERT_TYPE_INFO:
				blockingAlertActive = FALSE;
			break;
	}
#endif
}

// actually this is a hack to show blocking alerts which can be dismissed
-(void)showBlockingAlertWithTitle:(NSString*)title AndMessage:(NSString*)message OfType:(int)type
{
#ifndef NO_ALERTS
	[self showAlertWithTitle:title AndMessage:message OfType:type];
	blockingAlertActive = TRUE;

	while (blockingAlertActive)
	{
		while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
	}
#endif
}

-(void)setCurrentController:(ViewController*)c
{
	currentController = c;
	TimeType fps = (TimeType)[[Application sharedAppSettings] getInt:APP_SETTING_FPS];	
	currentController.idealDelta = (TimeType)1.0 / fps;
}

-(ViewController*)getCurrentController
{
	return currentController;
}

#ifndef NO_ALERTS
-(void)terminateApp:(int)code
{
	exit(code);
}
#endif

- (void)deactivate
{
	[super deactivate];
}

- (void)dealloc
{
	[timer stopTimer];
	[timer release];
	[systemAlert release];
	[screenGrabber release];
	[prevScreenImage release];
	[nextScreenImage release];
	[super dealloc];
}


@end
