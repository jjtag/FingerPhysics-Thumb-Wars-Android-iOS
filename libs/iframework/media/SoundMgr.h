//
//  SoundMgr.h
//  blockit
//
//  Created by Efim Voinov on 14.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import "Vector.h"
#import "OALSound.h"

#define DEFAULT_LISTENER_DISTANCE 25.0
#define REFERENCE_DISTANCE 50.0
#define MAX_SOUND_SOURCES 16
#define SESSION_CATEGORY kAudioSessionCategory_AmbientSound
// sound manager based on OpenAL
//
// at init creates MAX_SOUND_SOURCES sources and then binds buffers passed in playSound to the free sources.
// if all sources are occupied, overwrites them from the beginning 
//
// Supports playback of: uncompressed CAF and IMA4 encoded 

typedef struct SoundChannel
{
	ALuint source;
	ALuint	buffer;
	float gain;
	float pos;
	bool isPlaying;				
} SoundChannel;

@interface SoundMgr : NSObject
{
	ALCcontext* newContext;
	ALCdevice* newDevice;
	
	SoundChannel* channels;

	Vector sourcePos;
	Vector listenerPos;
	float listenerRotation;
	
	bool isSoundError;	
	bool isExternalAudioPlaying;
}

-(void)initOpenAL;
-(void)teardownOpenAL;

// use this to pre-bind buffer to a source for sound (this eliminates possible delay during first playback)
-(void)bind:(int)sid;

// 0..1
-(void)setVolume:(float)v forChannel:(int)c;

-(bool)isExternalAudioPlaying;
-(bool)isChannelPlaying:(int)c;
-(bool)isChannelPaused:(int)c;

-(void)playSound:(int)sid;
-(void)playSound:(int)sid Looped:(bool)l;
-(void)playSound:(int)sid atChannel:(int)c Looped:(bool)l;
-(void)playSound:(int)sid inChannelFrom:(int)s To:(int)e;
-(void)playSound:(int)sid inChannelFrom:(int)s To:(int)e Looped:(bool)l;
-(void)playChannel:(int)sourceNum;
-(void)playLowPrioritySound:(int)sid atChannel:(int)c Looped:(bool)l;

-(void)stopSound:(int)sid;
-(void)stopChannel:(int)c;
-(void)stopAllSounds;

-(void)vibrate;

-(void)suspend;
-(void)resume;

-(void)pause;
-(void)unpause;

-(void)pauseChannel:(int)c;
-(void)unpauseChannel:(int)c;

@property(readonly) bool isSoundError;

@end
