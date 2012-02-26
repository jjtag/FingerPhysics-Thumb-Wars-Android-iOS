//
//  Timer.m
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Timer.h"
#import "Debug.h"
#import "Application.h"

@implementation Timer

@synthesize target;
@synthesize selector;

- (id)init
{
	if (self = [super init])
	{
		target = nil;
		selector = nil;
	}
	
	return self;
}

// start update timer
- (void)startTimer 
{
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(internalUpdate) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    [updateTimer invalidate];
	updateTimer = nil;
}

- (void)setTimerInterval:(TimeType)interval 
{
    
    updateInterval = interval;
    if (updateTimer) 
	{
		[self stopTimer];
        [self startTimer];
    }
}

- (void)internalUpdate
{
	// don't fire timers when we are in a blocking alert
	if ([Application sharedRootController].blockingAlertActive)
	{
		return;
	}
	
	if (target)
	{
		[target performSelector:selector];
	}
	else
	{
		[self update];
	}
}

- (void)update
{
	ASSERT(updateTimer);
}

-(void)dealloc
{
   [self stopTimer];	
	[super dealloc];
}

@end
