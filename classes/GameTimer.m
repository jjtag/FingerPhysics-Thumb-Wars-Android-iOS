//
//  GameTimer.m
//  champions
//
//  Created by ikoryakin on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameTimer.h"
#import "Font.h"

@implementation GameTimer

-(id)initWithFont:(Font *)i
{
	if(self = [super initWithFont:i])
	{
		time = 0;
	}
	return self;
}

-(void)draw
{
	[super draw];
}

-(void)update:(TimeType)delta
{
	int min, sec;
	sec = (int)floor(time) % 60;
	min = MIN(99, (int)floor(time) / 60);
	
	[self setString:FORMAT_STRING(@"%02d:%02d", min, sec) andWidth:60];	
}


@end
