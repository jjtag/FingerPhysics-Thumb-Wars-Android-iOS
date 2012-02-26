//
//  OALSound.h
//  blockit
//
//  Created by Mac on 15.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

// sound object which can be played by openAL 
@interface OALSound : NSObject
{
	ALenum  format;
	ALvoid* data;
	ALsizei size;
	ALsizei freq;	

@public
	ALuint buffer;	
	bool looped;

	// if this is TRUE, we use the channel used for previous playback of this sound, otherwise we bind to a new one every new playback
	bool stayOnChannel; 
}
-(id)initWithPath:(NSString*)path;

@property (readonly) ALenum format;
@property (readonly) ALvoid* data;
@property (readonly) ALsizei size;
@property (readonly) ALsizei freq;	

@end
