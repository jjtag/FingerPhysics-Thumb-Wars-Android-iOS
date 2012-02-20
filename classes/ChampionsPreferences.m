//
//  ChampionsPreferences.m
//  champions
//
//  Created by Mac on 02.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChampionsPreferences.h"
#import "ChampionsResourceMgr.h"

const NSString* PREFS_IS_EXIST = @"PREFS_EXIST";
const NSString* PREFS_SOUND_ON = @"SOUND_ON";
const NSString* PREFS_MUSIC_ON = @"MUSIC_ON";

const NSString* TUTORIAL_MAPS[] = 
{
	@"1-tutorial-01.bim",
	@"1-tutorial-02.bim",
	@"1-tutorial-03.bim",
	@"1-tutorial-04.bim",
	@"1-tutorial-05-!pin!.bim",
	@"1-tutorial-06-gear.bim",
	@"1-tutorial-07-magnets.bim",
	@"1-tutorial-08.bim",
	@"1-tutorial-09.bim",
	@"2-tutorial-01.bim",
	@"2-tutorial-02.bim",
	@"2-tutorial-03.bim",
	@"2-tutorial-04.bim",
	@"2-tutorial-05.bim",
	@"2-tutorial-06.bim",			
};

@implementation ChampionsPreferences

-(id)init
{
	if (self = [super init])
	{
		if (![self getBooleanForKey:(NSString*)PREFS_IS_EXIST])
		{
			[self setBoolean:TRUE forKey:(NSString*)PREFS_IS_EXIST];
			[self resetToDefaults];
		}
	}
	
	return self;
}

-(void)resetToDefaults
{
	[self setBoolean:TRUE forKey:(NSString*)PREFS_SOUND_ON];
	[self setBoolean:TRUE forKey:(NSString*)PREFS_MUSIC_ON];
}

@end
