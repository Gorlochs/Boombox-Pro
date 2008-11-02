//
//  AudioStreamer.m
//  StreamingAudioPlayer
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "AudioStreamer.h"

#define PRINTERROR(LABEL)	printf("%s err %4.4s %d\n", LABEL, (char *)&err, (int)err)

void MyAudioQueueOutputCallback(void* inClientData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer);

void MyAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID);

void MyPropertyListenerProc(	void *							inClientData,
								AudioFileStreamID				inAudioFileStream,
								AudioFileStreamPropertyID		inPropertyID,
								UInt32 *						ioFlags);

void MyPacketsProc(				void *							inClientData,
								UInt32							inNumberBytes,
								UInt32							inNumberPackets,
								const void *					inInputData,
								AudioStreamPacketDescription	*inPacketDescriptions);

OSStatus MyEnqueueBuffer(AudioStreamer* myData);

void MyPropertyListenerProc(	void *							inClientData,
								AudioFileStreamID				inAudioFileStream,
								AudioFileStreamPropertyID		inPropertyID,
								UInt32 *						ioFlags)
{	
	// this is called by audio file stream when it finds property values
	AudioStreamer* myData = (AudioStreamer*)inClientData;
	OSStatus err = noErr;

//	printf("found property '%c%c%c%c'\n", (inPropertyID>>24)&255, (inPropertyID>>16)&255, (inPropertyID>>8)&255, inPropertyID&255);

	switch (inPropertyID) {
		case kAudioFileStreamProperty_ReadyToProducePackets :
		{
			myData->discontinuous = true;
			
			// the file stream parser is now ready to produce audio packets.
			// get the stream format.
			AudioStreamBasicDescription asbd;
			UInt32 asbdSize = sizeof(asbd);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
			if (err) { PRINTERROR("get kAudioFileStreamProperty_DataFormat"); myData->failed = true; break; }
			
			// create the audio queue
			err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, myData, NULL, NULL, 0, &myData->audioQueue);
			if (err) { PRINTERROR("AudioQueueNewOutput"); myData->failed = true; break; }
			
			// listen to the "isRunning" property
			err = AudioQueueAddPropertyListener(myData->audioQueue, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, myData);
			if (err) { PRINTERROR("AudioQueueAddPropertyListener"); myData->failed = true; break; }
			
			// allocate audio queue buffers
			for (unsigned int i = 0; i < kNumAQBufs; ++i) {
				err = AudioQueueAllocateBuffer(myData->audioQueue, kAQBufSize, &myData->audioQueueBuffer[i]);
				if (err) { PRINTERROR("AudioQueueAllocateBuffer"); myData->failed = true; break; }
			}

			// get the cookie size
			UInt32 cookieSize;
			Boolean writable;
			err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
			if (err) { PRINTERROR("info kAudioFileStreamProperty_MagicCookieData"); break; }
//			printf("cookieSize %d\n", cookieSize);

			// get the cookie data
			void* cookieData = calloc(1, cookieSize);
			err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
			if (err) { PRINTERROR("get kAudioFileStreamProperty_MagicCookieData"); free(cookieData); break; }

			// set the cookie on the queue.
			err = AudioQueueSetProperty(myData->audioQueue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
			free(cookieData);
			if (err) { PRINTERROR("set kAudioQueueProperty_MagicCookie"); break; }
			break;
		}
	}
}

void MyPacketsProc(				void *							inClientData,
								UInt32							inNumberBytes,
								UInt32							inNumberPackets,
								const void *					inInputData,
								AudioStreamPacketDescription	*inPacketDescriptions)
{
	// this is called by audio file stream when it finds packets of audio
	AudioStreamer* myData = (AudioStreamer*)inClientData;
//	printf("got data.  bytes: %d  packets: %d\n", inNumberBytes, inNumberPackets);

	myData->discontinuous = false;

	// the following code assumes we're streaming VBR data. for CBR data, the second branch is used.
	if (inPacketDescriptions)
	{
		for (int i = 0; i < inNumberPackets; ++i) {
			SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
			SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
			
			// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
			size_t bufSpaceRemaining = kAQBufSize - myData->bytesFilled;
			if (bufSpaceRemaining < packetSize) {
				MyEnqueueBuffer(myData);
			}
			
			// If the audio was terminated while waiting for a buffer, then
			// exit.
			if (myData->finished)
			{
				return;
			}
			
			// copy data to the audio queue buffer
			AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[myData->fillBufferIndex];
			memcpy((char*)fillBuf->mAudioData + myData->bytesFilled, (const char*)inInputData + packetOffset, packetSize);
			// fill out packet description
			myData->packetDescs[myData->packetsFilled] = inPacketDescriptions[i];
			myData->packetDescs[myData->packetsFilled].mStartOffset = myData->bytesFilled;
			// keep track of bytes filled and packets filled
			myData->bytesFilled += packetSize;
			myData->packetsFilled += 1;

			// if that was the last free packet description, then enqueue the buffer.
			size_t packetsDescsRemaining = kAQMaxPacketDescs - myData->packetsFilled;
			if (packetsDescsRemaining == 0) {
				MyEnqueueBuffer(myData);
			}
		}	
	}
	else
	{
		// if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
		size_t bufSpaceRemaining = kAQBufSize - myData->bytesFilled;
		if (bufSpaceRemaining < inNumberBytes) {
			MyEnqueueBuffer(myData);
		}
		
		// If the audio was terminated while waiting for a buffer, then
		// exit.
		if (myData->finished)
		{
			return;
		}
		
		// copy data to the audio queue buffer
		AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[myData->fillBufferIndex];
		memcpy((char*)fillBuf->mAudioData + myData->bytesFilled, (const char*)inInputData, inNumberBytes);

		// keep track of bytes filled and packets filled
		myData->bytesFilled += inNumberBytes;
		myData->packetsFilled = 0;
	}
}

OSStatus MyEnqueueBuffer(AudioStreamer* myData)
{
	OSStatus err = noErr;
	myData->inuse[myData->fillBufferIndex] = true;		// set in use flag
	
	// enqueue buffer
	AudioQueueBufferRef fillBuf = myData->audioQueueBuffer[myData->fillBufferIndex];
	fillBuf->mAudioDataByteSize = myData->bytesFilled;
	
	if (myData->packetsFilled)
	{
		err = AudioQueueEnqueueBuffer(myData->audioQueue, fillBuf, myData->packetsFilled, myData->packetDescs);
	}
	else
	{
		err = AudioQueueEnqueueBuffer(myData->audioQueue, fillBuf, 0, NULL);
	}
	
	if (err) { PRINTERROR("AudioQueueEnqueueBuffer"); myData->failed = true; return err; }		
	
	if (!myData->started) {		// start the queue if it has not been started already
		[myData retain];
		err = AudioQueueStart(myData->audioQueue, NULL);
		if (err) { PRINTERROR("AudioQueueStart"); myData->failed = true; return err; }		
		myData->started = true;
//		printf("started\n");
	}

	// go to next buffer
	if (++myData->fillBufferIndex >= kNumAQBufs) myData->fillBufferIndex = 0;
	myData->bytesFilled = 0;		// reset bytes filled
	myData->packetsFilled = 0;		// reset packets filled

	// wait until next buffer is not in use
//	printf("->lock\n");
	pthread_mutex_lock(&myData->mutex); 
	while (myData->inuse[myData->fillBufferIndex] && !myData->finished) {
//		printf("... WAITING ...\n");
		pthread_cond_wait(&myData->cond, &myData->mutex);
		
		if (myData->finished)
		{
			break;
		}
	}
	pthread_mutex_unlock(&myData->mutex);
//	printf("<-unlock\n");

	return err;
}

int MyFindQueueBuffer(AudioStreamer* myData, AudioQueueBufferRef inBuffer)
{
	for (unsigned int i = 0; i < kNumAQBufs; ++i) {
		if (inBuffer == myData->audioQueueBuffer[i]) 
			return i;
	}
	return -1;
}

void MyAudioQueueOutputCallback(	void*					inClientData, 
									AudioQueueRef			inAQ, 
									AudioQueueBufferRef		inBuffer)
{
	// this is called by the audio queue when it has finished decoding our data. 
	// The buffer is now free to be reused.
	AudioStreamer* myData = (AudioStreamer*)inClientData;
	unsigned int bufIndex = MyFindQueueBuffer(myData, inBuffer);
	
	// signal waiting thread that the buffer is free.
	pthread_mutex_lock(&myData->mutex);
	myData->inuse[bufIndex] = false;
	pthread_cond_signal(&myData->cond);
	pthread_mutex_unlock(&myData->mutex);
}

void MyAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
	AudioStreamer *myData = (AudioStreamer *)inUserData;

	myData.isPlaying = !myData.isPlaying;
	
	if (!myData.isPlaying)
	{
		myData->finished = true;
		[myData release];
		return;
	}
}

@implementation AudioStreamer

@synthesize isPlaying;

//
// initWithURL
//
// Init method for the object.
//
- (id)initWithURL:(NSURL *)newUrl
{
	self = [super init];
	if (self != nil)
	{
		url = [newUrl retain];
	}
	return self;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[url release];
	[connection release];
	[super dealloc];
}

- (void)startInternal
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	AudioFileTypeID fileTypeHint = 0;
	NSString *fileExtension = [[url path] pathExtension];
	if ([fileExtension isEqual:@"mp3"])
	{
		fileTypeHint = kAudioFileMP3Type;
	}
	else if ([fileExtension isEqual:@"wav"])
	{
		fileTypeHint = kAudioFileWAVEType;
	}
	else if ([fileExtension isEqual:@"aifc"])
	{
		fileTypeHint = kAudioFileAIFCType;
	}
	else if ([fileExtension isEqual:@"aiff"])
	{
		fileTypeHint = kAudioFileAIFFType;
	}
	else if ([fileExtension isEqual:@"m4a"])
	{
		fileTypeHint = kAudioFileM4AType;
	}
	else if ([fileExtension isEqual:@"mp4"])
	{
		fileTypeHint = kAudioFileMPEG4Type;
	}
	else if ([fileExtension isEqual:@"caf"])
	{
		fileTypeHint = kAudioFileCAFType;
	}
	else if ([fileExtension isEqual:@"aac"])
	{
		fileTypeHint = kAudioFileAAC_ADTSType;
	}

	// initialize a mutex and condition so that we can block on buffers in use.
	pthread_mutex_init(&mutex, NULL);
	pthread_cond_init(&cond, NULL);
	
	// create an audio file stream parser
	OSStatus err = AudioFileStreamOpen(self, MyPropertyListenerProc, MyPacketsProc, 
							fileTypeHint, &audioFileStream);
	if (err) { PRINTERROR("AudioFileStreamOpen"); return; }

	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	do
	{
		CFRunLoopRunInMode(
			kCFRunLoopDefaultMode,
			0.25,
			false);
		
		if (failed)
		{
			[self stop];

#ifdef TARGET_OS_IPHONE			
			UIAlertView *alert =
				[[UIAlertView alloc]
					initWithTitle:NSLocalizedStringFromTable(@"Audio Error", @"Errors", nil)
					message:NSLocalizedStringFromTable(@"Streaming audio failed for some reason but the lazy programmer can't be bothered telling you why.", @"Errors", nil)
					delegate:self
					cancelButtonTitle:@"OK"
					otherButtonTitles: nil];
			[alert
				performSelector:@selector(show)
				onThread:[NSThread mainThread]
				withObject:nil
				waitUntilDone:YES];
			[alert release];
#else
			NSAlert *alert =
				[NSAlert
					alertWithMessageText:NSLocalizedString(@"Lazy programmer error", @"")
					defaultButton:NSLocalizedString(@"OK", @"")
					alternateButton:nil
					otherButton:nil
					informativeTextWithFormat:@"Streaming audio failed for some reason but the lazy programmer can't be bothered telling you why."];
			[alert
				performSelector:@selector(runModal)
				onThread:[NSThread mainThread]
				withObject:nil waitUntilDone:NO];
#endif
			
			break;
		}
	} while (!finished || isPlaying);
	
	err = AudioFileStreamClose(audioFileStream);
	if (err) { PRINTERROR("AudioFileStreamClose"); return; }
	
	if (started)
	{
		err = AudioQueueDispose(audioQueue, true);
		if (err) { PRINTERROR("AudioQueueDispose"); return; }
	}

	[pool release];
}

- (void)start
{
	[NSThread detachNewThreadSelector:@selector(startInternal) toTarget:self withObject:nil];
}

- (void)stop
{
	if (connection)
	{
		[connection cancel];
		[connection release];
		connection = nil;
		
		if (started && !finished)
		{
			finished = true;
			
			OSStatus err = AudioQueueStop(audioQueue, true);
			if (err) { PRINTERROR("AudioQueueStop"); return; }

			pthread_mutex_lock(&mutex);
			pthread_cond_signal(&cond);
			pthread_mutex_unlock(&mutex);
		}
		else
		{
			self.isPlaying = true;
			self.isPlaying = false;
			finished = true;
		}
	}
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	return nil;
}

- (void)connection:(NSURLConnection*)inConnection didReceiveData:(NSData*)data
{
	if (failed)
	{
		return;
	}
	
	if (!finished)
	{
		if (discontinuous)
		{
			OSStatus err = AudioFileStreamParseBytes(audioFileStream, [data length], [data bytes], kAudioFileStreamParseFlag_Discontinuity);
			if (err) { PRINTERROR("AudioFileStreamParseBytes"); failed = true;}
		}
		else
		{
			OSStatus err = AudioFileStreamParseBytes(audioFileStream, [data length], [data bytes], 0);
			if (err) { PRINTERROR("AudioFileStreamParseBytes"); failed = true; }
		}
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection
{
	if (failed)
	{
		return;
	}
	
	if (!finished && started)
	{
		if (bytesFilled)
		{
			MyEnqueueBuffer(self);
		}

		OSStatus err = AudioQueueFlush(audioQueue);
		if (err) { PRINTERROR("AudioQueueFlush"); return; }
		
		err = AudioQueueStop(audioQueue, false);
		if (err) { PRINTERROR("AudioQueueStop"); return; }
	}
	else if (!started)
	{
		failed = YES;
		[self stop];
		return;
	}

	[connection release];
	connection = nil;
	
	NSLog(@"connectionDidFinishLoading and connection set to nil");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self stop];
}

@end
