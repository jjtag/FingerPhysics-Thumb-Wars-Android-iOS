//
//  Accel.m
//  blockit
//
//  Created by reaxion on 17.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Accelerometer.h"
#import "Debug.h"

#define kFilteringFactor 0.1

@implementation Accelerometer

@synthesize x, y, z;

-(void) startAccelerometerWithFrequency:(float) freq useFilter:(bool) filter useHighPassFilter:(bool) filtertype;
{
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / freq)];
		// [[UIAccelerometer sharedAccelerometer] setDelegate:self];

		useFilter = filter;
		useHighPassFilter = filtertype;
		filterFactor = kFilteringFactor;
}
-(void)stopAccelerometer
{
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

-(void)setFilterFactor:(float)f
{
	ASSERT(f >= 0.0 && f <= 1.0);
	filterFactor = f;
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if(useFilter == TRUE)
	{
		// low-pass filter
		x =  ( (acceleration.x * filterFactor) + (x * (1.0 - filterFactor)) );
		y =  ( (acceleration.y * filterFactor) + (y * (1.0 - filterFactor)) );
		z =  ( (acceleration.z * filterFactor) + (z * (1.0 - filterFactor)) );
		
		if(useHighPassFilter == TRUE)
		{
			x = acceleration.x - x;
			y = acceleration.y - y;
			z = acceleration.z - z;
		}
	}
	else
	{
		x = acceleration.x;
		y = acceleration.y;
		z = acceleration.z;
	}
}

-(void) dealloc
{
	[self stopAccelerometer];
	[super dealloc];
}

@end

