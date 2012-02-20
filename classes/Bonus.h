//
//  Bonus.h
//  champions
//
//  Created by ikoryakin on 4/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Framework.h"
#import "FPBody.h"

enum bonus_modes 
	{
		MODE_STATIC = 0,
		MODE_ACTIVE,
		MODE_VANISH,
		MODE_VANISHED,
	};

enum timelines {
	BONUS_ACTIVE_TIMELINE,
	BONUS_COLLECT_TIMELINE,
	BONUS_VANISH_TIMELINE,
};

@interface Bonus : Image <TimelineDelegate>
{
	FPBody* body;
	int mode;
	BOOL collected;
	float timer;
	Image* shadow;
}

-(void)setMode:(int)m;
-(void)drawShadow;

@property (retain) Image* shadow;
@property (retain) FPBody* body; 
@property (assign) int mode;
@property (assign) BOOL collected;
@property (assign) float timer;
@end
