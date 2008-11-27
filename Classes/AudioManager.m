//
//  AudioManager.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AudioManager.h"
#import "SynthesizeSingleton.h"

@interface AudioManager (Private)
- (void)insertSongIntoDB:(BlipSong*)songToInsert;
@end

@implementation AudioManager

@synthesize streamer;
@synthesize playlist;
@synthesize currentSong;
@synthesize searchTerms;
@synthesize songs;
@synthesize songIndexOfPlaylistCurrentlyPlaying;

SYNTHESIZE_SINGLETON_FOR_CLASS(AudioManager);

- (void) startStreamerWithSong:(BlipSong*)song {
	// just in case a stream is playing, stop the stream before starting a new one
	[self.streamer stop];
	
	// start the stream
	NSURL *url = [NSURL URLWithString:[[song location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	[self.streamer start];
	
	// inset song into DB
	[self insertSongIntoDB:song];
	
	// set currentSong
	currentSong = song;
	
	// set currently playing song to -1 (if this is a playlist song, the playlist function will set it correctly)
	songIndexOfPlaylistCurrentlyPlaying = -1;
	
	// start the network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) startStreamerWithPlaylistIndex:(NSInteger)playListIndex {
	// find song to play
	BlipSong *songToPlay = [playlist objectAtIndex:playListIndex];
	
	// set currentSong
	currentSong = songToPlay;
	
	// start stream
	[self startStreamerWithSong:songToPlay];
	
	// set currently playing index correctly
	songIndexOfPlaylistCurrentlyPlaying = playListIndex;
}

- (void) stopStreamer {
	// if streamer is stopped, then reset the currently playing index
	songIndexOfPlaylistCurrentlyPlaying = -1;

	// the current song is now nil, since there is no song playing
	currentSong = nil;
	
	// stop the streamer
	[self.streamer stop];
	
	// switch off the network activity indicator in the status bar
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)insertSongIntoDB:(BlipSong*)songToInsert {
	NSURL *insertUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://literalshore.com/gorloch/blip/insert.php?song=%@&artist=%@&gkey=g0rl0ch1an5", 
											 [[songToInsert.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
											 [[songToInsert.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	NSLog(@"insert url: %@", insertUrl);
	NSString *insertResult = [NSString stringWithContentsOfURL:insertUrl];
	NSLog(@"insert result: %@", insertResult);
}

- (BOOL) isSongPlaying:(BlipSong*)song {
	return [[song location] isEqualToString:[[self.streamer getUrl] absoluteString]];
}

@end
