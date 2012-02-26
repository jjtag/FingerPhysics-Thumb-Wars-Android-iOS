//
//  SoundMgr.m
//  blockit
//
//  Created by Efim Voinov on 14.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SoundMgr.h"
#import "Vector.h"
#import "Debug.h"
#import "Application.h"
#import <AudioToolbox/AudioServices.h>

#ifdef ALERT_OPENAL_ERRORS
	#define CHECK_AL_ERRORS {ALenum err = alGetError(); \
		if (err != 0) ASSERT_MSG(FALSE, FORMAT_STRING(@"OpenAL error: %d", err));}
#else
	#define CHECK_AL_ERRORS {ALenum err = alGetError(); \
	if (err != 0) LOG_GROUPF(SND,@"OpenAL error: %d", err);}
#endif

void interruptionListener(void* inClientData, UInt32 inInterruptionState)
{
	SoundMgr* this = (SoundMgr*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		[this suspend];
	}
	else if (inInterruptionState == kAudioSessionEndInterruption)
	{
		[this resume];
	}
}

@implementation SoundMgr 

@synthesize isSoundError;

- (id)init
{	
	isSoundError = false;
	if (self = [super init]) 
	{
		channels = (SoundChannel*) malloc(sizeof(SoundChannel) * MAX_SOUND_SOURCES);

		bzero(channels, sizeof(SoundChannel) * MAX_SOUND_SOURCES);

		ASSERT(channels);
		
		// Start with sound source slightly in front of the listener
		sourcePos = vect(0.0, -70.0);
		
		// Put the listener in the center of the stage
		listenerPos = vect(0.0, 0.0);
		
		// Listener looking straight ahead
		listenerRotation = 0.0;
		
		// setup audio session
		OSStatus result = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
		if (result) 
		{
			LOG_GROUPF(SND, @"Error initializing audio session! %d\n", result);
			isSoundError = true;
		}
		else 
		{
			UInt32 category = SESSION_CATEGORY;
			result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
			if (result) 
			{
				LOG_GROUPF(SND, @"Error setting audio session category! %d\n", result);
				isSoundError = true;
			}			
			else 
			{
				result = AudioSessionSetActive(true);
				if (result) 
				{
					LOG_GROUPF(SND, @"Error setting audio session active! %d\n", result);
					isSoundError = true;
				}
			}
		}
		
		UInt32 playingSize = 4;
		UInt32 playing = 0;
		
		AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &playingSize, &playing);
		isExternalAudioPlaying = playing != 0;				
		
		// Initialize OpenAL environment
		[self initOpenAL];
	}
	
	return self;
}

- (void)dealloc
{
	[self teardownOpenAL];
	ASSERT(channels);
	free(channels);
	[super dealloc];
}

-(void)setVolume:(float)v forChannel:(int)c
{
	ASSERT(c >= 0 && c < MAX_SOUND_SOURCES);
	channels[c].gain = v;
	alSourcef(channels[c].source, AL_GAIN, v);	
}

- (void)initSources
{
	// code for Hackintosh
	if (isSoundError) return;

	//ALenum error = AL_NO_ERROR;
	//alGetError(); // Clear the error

	// Set Source Position
	float sourcePosAL[] = {sourcePos.x, sourcePos.y, DEFAULT_LISTENER_DISTANCE};	
	
	for (int i = 0; i < MAX_SOUND_SOURCES; i++)
	{
		// Create some OpenAL source objects
		alGenSources(1, &channels[i].source);		
				
		alSourcefv(channels[i].source, AL_POSITION, sourcePosAL);
		
		// set source reference distance
		alSourcef(channels[i].source, AL_REFERENCE_DISTANCE, REFERENCE_DISTANCE);

		CHECK_AL_ERRORS;		
	}
}

- (void)initOpenAL
{
	if (isSoundError) return;
	//ALenum error;
	
	// Create a new OpenAL Device
	// Pass NULL to specify the system’s default output device
	newDevice = alcOpenDevice(NULL);
	if (newDevice != NULL)
	{
		// Create a new OpenAL Context
		// The new context will render to the OpenAL Device just created 
		newContext = alcCreateContext(newDevice, 0);
		if (newContext != NULL)
		{
			// Make the new context the Current OpenAL Context
			alcMakeContextCurrent(newContext);					
		}
	}
	
	[self initSources];
}

-(void)suspend
{
	// Deactivate the current audio session
	AudioSessionSetActive(NO);
	
	// set the current context to NULL will 'shutdown' openAL
	alcMakeContextCurrent(NULL);
	// now suspend your context to 'pause' your sound world
	alcSuspendContext(newContext);
	
	CHECK_AL_ERRORS;	
}

-(void)resume
{
	// Reset audio session
	UInt32 category = SESSION_CATEGORY;
	AudioSessionSetProperty ( kAudioSessionProperty_AudioCategory, sizeof(category), &category);
	
	// Reactivate the current audio session
	AudioSessionSetActive(YES);
	
	// Restore open al context
	alcMakeContextCurrent(newContext);
	// 'unpause' my context
	alcProcessContext(newContext);
	
	CHECK_AL_ERRORS;	
}

- (void)teardownOpenAL
{
    ALCcontext	*context = NULL;
    ALCdevice	*device = NULL;
	
	// Delete the Sources
	for (int i = 0; i < MAX_SOUND_SOURCES; i++)
	{
		alDeleteSources(1, &channels[i].source);
	}
	
	//Get active context (there can only be one)
    context = alcGetCurrentContext();
    //Get device for active context
    device = alcGetContextsDevice(context);
    //Release context
    alcDestroyContext(context);
    //Close device
    alcCloseDevice(device);
	
	CHECK_AL_ERRORS;	
}

-(void)bind:(int)sid
{
	//ALenum error;
	
	OALSound* sound = [[Application sharedResourceMgr] getResource:sid];
	ASSERT(sound);

	for (int i = 0; i < MAX_SOUND_SOURCES; i++)
	{		
		if (channels[i].buffer == 0)
		{			
			channels[i].buffer = sound->buffer;
			alSourcei(channels[i].source, AL_BUFFER, channels[i].buffer);				
			alSourcei(channels[i].source, AL_LOOPING, sound->looped);		
		}
	}
}

-(void)stopAllSounds
{
	for (int i = 0; i < MAX_SOUND_SOURCES; i++)
	{
		if (channels[i].buffer != 0)
		{		
			alSourceStop(channels[i].source);
			channels[i].isPlaying = FALSE;
		}		
	}
}

-(bool)isExternalAudioPlaying
{
	return isExternalAudioPlaying;
}

-(void)playLowPrioritySound:(int)sid atChannel:(int)c Looped:(bool)l
{
	ALenum state;
	alGetSourcei(channels[c].source, AL_SOURCE_STATE, &state);
	if( state == AL_PLAYING)
		return;
	[self playSound:sid atChannel:c Looped:l];
}

- (void)playSound:(int)sid atChannel:(int)c Looped:(bool)l
{
	if (isSoundError) return;
	//ALenum error;
	
	OALSound* sound = [[Application sharedResourceMgr] getResource:sid];
	ASSERT(sound);	
	sound->looped = l;

	if (channels[c].buffer != 0)
	{		
		alSourceStop(channels[c].source);								
	}

	if (channels[c].buffer != sound->buffer)
	{
		channels[c].buffer = sound->buffer;
		alSourcei(channels[c].source, AL_BUFFER, channels[c].buffer);
	}
	
	alSourcei(channels[c].source, AL_LOOPING, sound->looped);	
	
	[self playChannel:c];
}

-(bool)isChannelPlaying:(int)c
{
	ALenum state;
	alGetSourcei(channels[c].source, AL_SOURCE_STATE, &state);
	return (state == AL_PLAYING);
}

-(bool)isChannelPaused:(int)c
{
	ALenum state;
	alGetSourcei(channels[c].source, AL_SOURCE_STATE, &state);
	return (state == AL_PAUSED);
}

-(void)playChannel:(int)sourceNum
{
	//ALenum error;		

	// begin playing
	alSourcePlay(channels[sourceNum].source);
	
	CHECK_AL_ERRORS;
	channels[sourceNum].isPlaying = TRUE;	
}

-(void)playSound:(int)sid Looped:(bool)l
{
	OALSound* sound = [[Application sharedResourceMgr] getResource:sid];
	ASSERT(sound);
	sound->looped = l;
	[self playSound:sid];
}

-(void)playSound:(int)sid inChannelFrom:(int)s To:(int)e Looped:(bool)l
{
	OALSound* sound = [[Application sharedResourceMgr] getResource:sid];
	ASSERT(sound);
	sound->looped = l;	
	[self playSound:sid inChannelFrom:s To:e];
}

-(void)playSound:(int)sid inChannelFrom:(int)s To:(int)e
{
	if (isSoundError) return;
	
	OALSound* sound = [[Application sharedResourceMgr] getResource:sid];
	ASSERT(sound);
	
	LOG_GROUPF(SND, @"Play sound: %d", sound->buffer);
	
	int sourceNum = UNDEFINED;
	for (int i = s; i <= e; i++)
	{
		// we already have sound buffer binded to source
		if (sound->stayOnChannel && channels[i].buffer == sound->buffer)
		{
			sourceNum = i;
			alSourceStop(channels[sourceNum].source);	
			break;
		}		
		
		// found first empty source, bind buffer to it OR		
		// we don't have emtpy buffers, overwrite one
		if (channels[i].buffer == 0 ||
			(i == e && sourceNum == UNDEFINED))
		{			
			// stop playback
			if (channels[i].buffer != 0)
			{								
				for (int j = s; j <= e; j++)
				{
					if (![self isChannelPlaying:j])
					{
						sourceNum = j;				
						alSourceStop(channels[sourceNum].source);								
						break;
					}
				}
				ASSERT_MSG(sourceNum != UNDEFINED, @"Too many sounds are playing simultaneosly");
			}
			else
			{
				sourceNum = i;											
			}		
			
			channels[sourceNum].buffer = sound->buffer;
			alSourcei(channels[sourceNum].source, AL_BUFFER, channels[sourceNum].buffer);				
			alSourcei(channels[sourceNum].source, AL_LOOPING, sound->looped);			
			break;			
		}
	}
	
	[self playChannel:sourceNum];	
}

- (void)playSound:(int)sid 
{
	[self playSound:sid inChannelFrom:0 To:(MAX_SOUND_SOURCES - 1)];
}

-(void)vibrate
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);	
}

- (void)stopSound:(int)sid
{
	if (isSoundError) return;
	
	//ALenum error;
	
	OALSound* sound = [[Application sharedResourceMgr] getResource:sid];
	ASSERT(sound);	
	
	LOG_GROUPF(SND, @"Stop sound: %d", sound->buffer);

	int sourceNum = UNDEFINED;
	for (int i = 0; i < MAX_SOUND_SOURCES; i++)
	{
		if (channels[i].buffer == sound->buffer)
		{
			sourceNum = i;
			break;
		}
	}
	
	if (sourceNum == UNDEFINED)
	{
		LOG_GROUPF(SND, @"Can't find sound to stop: %d", sound->buffer);
		return;
	}
	[self stopChannel:sourceNum];
}

-(void)pause
{
	for (int i = 0; i < MAX_SOUND_SOURCES; i++)
	{	
		if ([self isChannelPlaying:i])
		{
			alSourcePause(channels[i].source);
			CHECK_AL_ERRORS;
		}
	}	
}

-(void)unpause
{
	for (int i = 0; i < MAX_SOUND_SOURCES; i++)
	{	
		if ([self isChannelPaused:i])
		{
			alSourcePlay(channels[i].source);
			CHECK_AL_ERRORS;			
		}
	}	
	
}

-(void)stopChannel:(int)c
{
	ASSERT(c >= 0 && c < MAX_SOUND_SOURCES);
	
	// Stop playing our source file
	alSourceStop(channels[c].source);
	
	CHECK_AL_ERRORS;
	
	// Mark our state as not playing (the view looks at this)
	channels[c].isPlaying = FALSE;	
}

-(void)pauseChannel:(int)c
{
	if ([self isChannelPlaying:c])
	{
		alSourcePause(channels[c].source);
		CHECK_AL_ERRORS;
	}
}

-(void)unpauseChannel:(int)c
{
	if ([self isChannelPaused:c])
	{
		alSourcePlay(channels[c].source);
		CHECK_AL_ERRORS;			
	}	
}

@end
