//
//  Accel.h
//  blockit
//
//  Created by reaxion on 17.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// accelerometer wrapper
@interface Accelerometer: NSObject
{
	UIAccelerationValue x, y, z;
	bool useFilter, useHighPassFilter;
	float filterFactor;
}
-(void)startAccelerometerWithFrequency:(float) freq useFilter:(bool) filter useHighPassFilter:(bool) filtertype;
-(void)stopAccelerometer;
-(void)setFilterFactor:(float)f;
@property (readonly) UIAccelerationValue ax, ay, az;

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;

-(void)dealloc;

@end