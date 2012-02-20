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
