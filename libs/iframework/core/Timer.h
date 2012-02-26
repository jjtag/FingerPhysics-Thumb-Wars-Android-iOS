//
//  Timer.h
//  blockit
//
//  Created by Efim Voinov on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FrameworkTypes.h"

// simple timer wrapper 
// which invokes "update" every updateInterval ms
@interface Timer : NSObject
{
@private
	id target;
	SEL selector;
	
@protected	
	NSTimer* updateTimer;
    double updateInterval;
}

- (void)startTimer;
- (void)stopTimer;
- (void)update;
- (void)setTimerInterval:(TimeType)interval;
- (void)internalUpdate;

// use this properties to set custom method which will be invoked
@property (assign) id target;
@property (assign) SEL selector;

@end
