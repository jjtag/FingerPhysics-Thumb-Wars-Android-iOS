//
//  OALSound.m
//  blockit
//
//  Created by Mac on 15.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OALSound.h"
#import <AudioToolbox/AudioFile.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "Debug.h"
#import <UIKit/UIKit.h>
#import "FrameworkTypes.h"

// IMA4 magic number tables
static int32_t ima_index_table[16] =
{
	-1, -1, -1, -1, 2, 4, 6, 8,
	-1, -1, -1, -1, 2, 4, 6, 8
};

static int32_t ima_step_table[89] =
{
	7, 8, 9, 10, 11, 12, 13, 14, 16, 17,
	19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
	50, 55, 60, 66, 73, 80, 88, 97, 107, 118,
	130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
	337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
	876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
	2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
	5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
	15289, 16818, 18500, 20350,  22385, 24623, 27086, 29794, 32767
};

AudioFileID openAudioFile(NSString* filePath)
{
	AudioFileID outAFID;
	// use the NSURl instead of a cfurlref cuz it is easier
	NSURL * afUrl = [NSURL fileURLWithPath:filePath];
	
	// do some platform specific stuff..
#if TARGET_OS_IPHONE
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
#else
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, fsRdPerm, 0, &outAFID);
#endif
	if (result != 0) ASSERT_MSG(FALSE, @"cannot openf file: %@");
	return outAFID;
}

// find the audio portion of the file
// return the size in bytes
UInt32 audioFileSize(AudioFileID fileDescriptor)
{
	UInt64 outDataSize = 0;
	UInt32 thePropSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
	if (result != 0) ASSERT_MSG(FALSE, @"cannot openf file");
	return (UInt32)outDataSize;
}

// find the audio portion of the file
// return the size in bytes
UInt32 audioPacketsCount(AudioFileID fileDescriptor)
{
	UInt64 outPacketsCount = 0;
	UInt32 thePropSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataPacketCount, &thePropSize, &outPacketsCount);
	if (result != 0) ASSERT_MSG(FALSE, @"cannot openf file");
	return (UInt32)outPacketsCount;
}

AudioStreamBasicDescription audioFileFormat(AudioFileID fileDescriptor)
{
	AudioStreamBasicDescription outDataFormat;
	UInt32 thePropSize = sizeof(AudioStreamBasicDescription);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyDataFormat, &thePropSize, &outDataFormat);
	if (result != 0) ASSERT_MSG(FALSE, @"cannot openf format: %@");
	return outDataFormat;
}

void decompressIMAPacket( const uint8_t* pSrc, int16_t* pDst, int32_t stride )
{
    // Read packet header
    uint16_t value  = *(uint16_t*)pSrc;
    uint16_t header = ( value >> 8 ) | ( value << 8 );
    int32_t predictor  = header & 0xff80;
    int32_t step_index = header & 0x007f;
    int32_t step, nibble, diff;
	
    // Sign extend predictor
    if( predictor & 0x8000 )
        predictor |= 0xffff0000;
	
    // Skip header
    pSrc += 2;
	
    // Read 64 nibbles, 2 at a time
    UInt32 byteCount = 32;
    while( byteCount-- )
    {
        // Read 2 nibbles
        uint8_t byte = *pSrc++;
		
        // Process low nibble
        nibble = byte & 0x0f;
        if( step_index < 0 ) step_index = 0;
        else if( step_index > 88 ) step_index = 88;
        step = ima_step_table[ step_index ];
        step_index += ima_index_table[ nibble ];
        diff = step >> 3;
        if (nibble & 4) diff += step;
        if (nibble & 2) diff += (step >> 1);
        if (nibble & 1) diff += (step >> 2);
        if (nibble & 8) predictor -= diff;
        else predictor += diff;
        if( predictor < -32768 ) predictor = -32768;
        else if( predictor > 32767 ) predictor = 32767;
        *pDst = predictor;
        pDst += stride;
		
        // Process high nibble
        nibble = byte >> 4;
        if( step_index < 0 ) step_index = 0;
        else if( step_index > 88 ) step_index = 88;
        step = ima_step_table[ step_index ];
        step_index += ima_index_table[ nibble ];
        diff = step >> 3;
        if (nibble & 4) diff += step;
        if (nibble & 2) diff += (step >> 1);
        if (nibble & 1) diff += (step >> 2);
        if (nibble & 8) predictor -= diff;
        else predictor += diff;
        if( predictor < -32768 ) predictor = -32768;
        else if( predictor > 32767 ) predictor = 32767;
        *pDst = predictor;
        pDst += stride;
    }
}

void decompressIMA( int32_t packetCount, bool stereo, const uint8_t* pSrc, int16_t* pDst )
{
    // Stereo?
    if (stereo)
    {
        // Decompress all stereo packets
        while( packetCount > 0 )
        {
            // Decompress channel0 and channel1 interleaved
            decompressIMAPacket( &pSrc[0],  &pDst[0], 2 );
            decompressIMAPacket( &pSrc[34], &pDst[1], 2 );
			
            // Next 2 channel packets
            pSrc += 34*2;
            pDst += 64*2;
            packetCount -= 2;
        }
    }
    else
    {
        // Decompress all mono packets
        while( packetCount-- )
        {
            // Decompress single channel
            decompressIMAPacket( pSrc, pDst, 1 );
			
            // Next channel packet
            pSrc += 34;
            pDst += 64;
        }
    }
}

typedef ALvoid	AL_APIENTRY	(*alBufferDataStaticProcPtr) (const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq);

ALvoid  alBufferDataStaticProc(const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq)
{
	static	alBufferDataStaticProcPtr	proc = NULL;
    
    if (proc == NULL)
	{
        proc = (alBufferDataStaticProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alBufferDataStatic");
    }
    
    if (proc)
        proc(bid, format, data, size, freq);
	
    return;
}

@implementation OALSound

@synthesize format;
@synthesize data;
@synthesize size;
@synthesize freq;

- (id) initWithPath:(NSString*)path
{
	if (!(self = [super init]))
	{
		return nil;
	}
	
	looped = FALSE;
	stayOnChannel = TRUE;	
	
	ASSERT(!data);
	
	ALenum error = AL_NO_ERROR;
	
	alGenBuffers(1, &buffer);	
	
	if((error = alGetError()) != AL_NO_ERROR) 
	{
		LOG_GROUPF(SND, @"error generating buffer: %x", error);
		//ASSERT(FALSE);
	}	
	
	AudioFileID fileID = openAudioFile(path);
	
	// find out how big the actual audio data is
	size = audioFileSize(fileID);	
	ALsizei packets = audioPacketsCount(fileID);
	AudioStreamBasicDescription desc = audioFileFormat(fileID);

	format = UNDEFINED;

	if (desc.mBitsPerChannel == 8)
	{
		format = (desc.mChannelsPerFrame == 1) ? AL_FORMAT_MONO8 : AL_FORMAT_STEREO8;
	}
	else
	{
		format = (desc.mChannelsPerFrame == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;		
	}
	
	ASSERT(format != UNDEFINED);
	
	freq = desc.mSampleRate;

	OSStatus result = noErr;	
	
	// handle IMA4 compressed audio
	if (desc.mFormatID == kAudioFormatAppleIMA4)
	{
		char* tmpData = malloc(size);
		ASSERT(tmpData);

		AudioStreamPacketDescription pdesc;
		result = AudioFileReadPackets(fileID, false, (UInt32*)&size, &pdesc, 0, (UInt32*)&packets, tmpData);

		int decompressedSize = packets * 128;		
		
		data = malloc(decompressedSize);
		ASSERT(data);
		size = decompressedSize;
		decompressIMA(packets, desc.mChannelsPerFrame == 2, (uint8_t*)tmpData, (int16_t*)data);
		free(tmpData);
	}
	else
	{
		// this is where the audio data will live for the moment
		data = malloc(size);
	
		// this where we actually get the bytes from the file and put them
		// into the data buffer
		result = AudioFileReadBytes(fileID, false, 0, (UInt32*)&size, data);
	}
	
	if (result != 0) LOGF(@"cannot load sound: %@", path);
	
	
	// jam the audio data into the new buffer
	alBufferDataStaticProc(buffer, format, data, size, freq);

	return self;
}

-(void)dealloc
{
    alDeleteBuffers(1, &buffer);

	ASSERT(data);
	free(data);
	[super dealloc];
}

@end