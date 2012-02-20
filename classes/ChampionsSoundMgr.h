//
//  ChampionsSoundMgr.h
//  champions
//
//  Created by Mac on 03.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SoundMgr.h"

@interface ChampionsSoundMgr : SoundMgr
{
}

+(void)playSound:(int)s;
+(void)playMusic:(int)m;
+(void)stopAll;
+(void)stopMusic;

+(void)pause;
+(void)unpause;

+(void)pauseMusic;
+(void)unpauseMusic;

@end
