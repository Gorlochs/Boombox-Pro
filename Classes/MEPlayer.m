//
//  MEPlayer.m
//  audio-test
//
//  Created by Shawn Bernard on 10/19/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import "MEPlayer.h"

void MyPropertyListenerProc(void *inClientData, AudioFileStreamID inAudioFileStream,AudioFileStreamPropertyID	inPropertyID, UInt32 * ioFlags)
{
	MEPlayer *player = (MEPlayer*)inClientData;
	[player propertyChanged:inPropertyID flags:ioFlags];
}

void MyPacketsProc(void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets, const void * inInputData, AudioStreamPacketDescription	*inPacketDescriptions)
{
	MEPlayer *player = (MEPlayer*)inClientData;
	[player packetData:inInputData  numberOfPackets:inNumberPackets numberOfBytes:inNumberBytes packetDescriptions:inPacketDescriptions];
}

void MyAudioQueueOutputCallback(void *inClientData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
	MEPlayer *player = (MEPlayer*)inClientData;
	[player outputCallbackWithBufferReference:inBuffer];
}


@implementation MEPlayer

- (void)init {
	
	audioState	= EAudioStateStopped;
}

- (void)playUrl:(NSString*)url
{
	
	NSLog(@"playUrl");
	OSStatus err = AudioFileStreamOpen(self, MyPropertyListenerProc, MyPacketsProc, 0, &audioFileStream);
	if (!err) NSLog(@"AudioFileStreamOpen ok");
	else NSLog(@"AudioFileStreamOpen nok");
	
	request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (connection)
		NSLog(@"connection created");
	else
		NSLog(@"connection failed");
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	OSStatus err = AudioFileStreamParseBytes(audioFileStream, [data length], [data bytes], 0);
	if (err) NSLog(@"AudioFileStreamParseBytes failed");
}

- (void)propertyChanged:(AudioFileStreamPropertyID)propertyID flags:(UInt32*)flags
{
	NSLog(@"found property '%c%c%c%c'\n", (propertyID>>24)&255, (propertyID>>16)&255, (propertyID>>8)&255, propertyID&255);
	
	OSStatus err = noErr;
	
	switch (propertyID)
	{
		case kAudioFileStreamProperty_ReadyToProducePackets:
		{
			AudioStreamBasicDescription asbd;
			UInt32 asbdSize = sizeof(asbd);
			
			err = AudioFileStreamGetProperty(audioFileStream,  kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
			if (err) NSLog(@"get kAudioFileStreamProperty_DataFormat failed");
			
			err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, self, NULL, NULL, 0, &audioQueue);
			if (err) NSLog(@"AudioQueueNewOutput failed");
			
			for (unsigned int i = 0; i < kNumAQBufs; i++)
				err = AudioQueueAllocateBuffer(audioQueue, kAQBufSize, &audioQueueBuffer[i]);
			break;
		}
	}
}

- (void)packetData:(const void*)data numberOfPackets:(UInt32)numPackets numberOfBytes:(UInt32)numBytes packetDescriptions:(AudioStreamPacketDescription*)packetDescriptions
{
	//NSLog(@"got data. bytes: %d, packets: %d", numBytes, numPackets);
	
	for (int i = 0; i < numPackets; i++)
	{
		SInt64 packetOffset = packetDescriptions[i].mStartOffset;
		SInt64 packetSize = packetDescriptions[i].mDataByteSize;
		
		size_t bufSpaceRemaining = kAQBufSize - bytesFilled;
		if (bufSpaceRemaining < packetSize) [self enqueueBuffer];
		
		AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
		memcpy((char*)fillBuf->mAudioData + bytesFilled, (const char*)data + packetOffset, packetSize);
		packetDescs[packetsFilled] = packetDescriptions[i];
		packetDescs[packetsFilled].mStartOffset = bytesFilled;
		bytesFilled += packetSize;
		packetsFilled += 1;
		
		size_t packetsDescsRemaining = kAQMaxPacketDescs - packetsFilled;
		if (packetsDescsRemaining == 0) [self enqueueBuffer];
	}
}

- (void)enqueueBuffer
{
	OSStatus err = noErr;
	inuse[fillBufferIndex] = true;
	
	AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
	fillBuf->mAudioDataByteSize = bytesFilled;
	err = AudioQueueEnqueueBuffer(audioQueue, fillBuf, packetsFilled, packetDescs);
	if (err) NSLog(@"AudioQueueEnqueueBuffer failed");
	
	if (!started)
	{
		err = AudioQueueStart(audioQueue, NULL);
		if (err) NSLog(@"AudioQueueStart failed");
		started = true;
		NSLog(@"started.");
		audioState	= EAudioStatePlaying;
	}
	
	if (++fillBufferIndex >= kNumAQBufs) fillBufferIndex = 0;
	bytesFilled = 0;
	packetsFilled = 0;
	
	NSLog(@"lock.");
	while (inuse[fillBufferIndex])
		NSLog(@"wait...");
	NSLog(@"unlock.");
	
}

- (int)findQueueBuffer:(AudioQueueBufferRef)inBuffer
{
	for (unsigned int i = 0; i < kNumAQBufs; i++)
	{
		if (inBuffer == audioQueueBuffer[i]) return i;
	}
	return -1;
}

- (void)outputCallbackWithBufferReference:(AudioQueueBufferRef)buffer
{
	unsigned int bufIndex = [self findQueueBuffer:buffer];
	
	inuse[bufIndex] = false;
}

- (void)close
{
	// it is preferrable to call close first, before dealloc if there is a problem waiting for an autorelease
	audioState	= EAudioStateClosed;
	
	if (trackClosed) return;
	
	trackClosed = YES;
	AudioQueueStop(audioQueue, YES);
	AudioQueueDispose(audioQueue, YES);
	AudioFileStreamClose(audioFileStream);
	free(packetDescs);
	//packetDescs = nil;
}

- (void)dealloc
{
	[self close];
	[super dealloc];
}

@end