//
//  Timer.h
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FrameworkTypes.h"

@protocol TimerDelegate <NSObject>

- (void)onTimerFired;

@end

// simple timer wrapper 
// which invokes "update" every updateInterval ms
@interface Timer : NSObject
{
@private
	id<TimerDelegate> delegate;
@protected	
	NSTimer* updateTimer;
    double updateInterval;
}

@property (nonatomic, assign) id<TimerDelegate> delegate;

- (void)startTimer;
- (void)stopTimer;
- (void)update;
- (void)setTimerInterval:(TimeType)interval;
- (void)internalUpdate;

@end
