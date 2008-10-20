//
//  MEPlayer.h
//  audio-test
//
//  Created by Shawn Bernard on 10/19/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFileStream.h>


#define kNumAQBufs	3			// number of audio queue buffers we allocate
#define kAQMaxPacketDescs   128
#define kAQBufSize			1 * 1024

typedef enum {
	EAudioStateClosed,
	EAudioStateStopped,
	EAudioStatePlaying,
	EAudioStatePaused,
	EAudioStateSeeking
} EAudioState;


@interface MEPlayer : NSObject
{
	AudioFileStreamID				audioFileStream;
	AudioQueueRef					audioQueue;
	AudioQueueBufferRef				audioQueueBuffer[kNumAQBufs];
	AudioStreamPacketDescription	packetDescs[kAQMaxPacketDescs];
	
	NSURLConnection					*connection;
	NSURLRequest					*request;
	
	UInt64							fillBufferIndex;
	UInt32							bytesFilled;	
	UInt32							packetsFilled;
	
	UInt64							packetIndex;
	UInt32							numPacketsToRead;
	
	BOOL							inuse[kNumAQBufs];	
	BOOL							started;			
	BOOL							failed;	
	BOOL							repeat;
	BOOL							trackClosed;
	
	EAudioState						audioState;
}

- (void)init;
- (void)playUrl:(NSString*)url;
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data;
- (void)propertyChanged:(AudioFileStreamPropertyID)propertyID flags:(UInt32*)flags;
- (void)packetData:(const void*)data
   numberOfPackets:(UInt32)numPackets
	 numberOfBytes:(UInt32)numBytes
packetDescriptions:(AudioStreamPacketDescription*)packetDescriptions;

- (void)enqueueBuffer;
- (int)findQueueBuffer:(AudioQueueBufferRef)inBuffer;
- (void)outputCallbackWithBufferReference:(AudioQueueBufferRef)buffer;
- (void)close;
- (void)dealloc;

@end