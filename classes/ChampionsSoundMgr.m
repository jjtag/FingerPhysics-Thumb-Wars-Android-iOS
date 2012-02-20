//
//  ChampionsSoundMgr.m
//  champions
//
//  Created by Mac on 03.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChampionsSoundMgr.h"
#import "ChampionsPreferences.h"
#import "Framework.h"

@implementation ChampionsSoundMgr

+(void)playSound:(int)s
{
	ChampionsPreferences* prefs = (ChampionsPreferences*)[Application sharedPreferences];
	if ([prefs getBooleanForKey:(NSString*)PREFS_SOUND_ON])
	{
		[[Application sharedSoundMgr] playSound:s inChannelFrom:1 To:MAX_SOUND_SOURCES - 1];
	}
}

+(void)playMusic:(int)m
{
	ChampionsPreferences* prefs = (ChampionsPreferences*)[Application sharedPreferences];
	if ([prefs getBooleanForKey:(NSString*)PREFS_MUSIC_ON])
	{
		ChampionsSoundMgr* sm = (ChampionsSoundMgr*)[Application sharedSoundMgr];
		if (![sm isChannelPlaying:0] && ![sm isExternalAudioPlaying])
		{
			[[Application sharedSoundMgr] playSound:m atChannel:0 Looped:TRUE];
		}
	}
}

+(void)stopAll
{
	[[Application sharedSoundMgr] stopAllSounds];
}

+(void)stopMusic
{
	[[Application sharedSoundMgr] stopChannel:0];
}

+(void)pause
{
	[[Application sharedSoundMgr] pause];
}

+(void)unpause
{
	[[Application sharedSoundMgr] unpause];	
}

+(void)pauseMusic
{
	[[Application sharedSoundMgr] pauseChannel:0];
}

+(void)unpauseMusic
{
	[[Application sharedSoundMgr] unpauseChannel:0];
}

@end
