//
//  AudioManager.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AudioManager.h"
#import "SynthesizeSingleton.h"
#import "iPhoneStreamingPlayerAppDelegate.h"
#import "Reachability.h"

#define MAX_SONGS_FOR_CELL_NETWORK_PER_DAY 15

@interface AudioManager (Private)
- (void)insertSongIntoDB:(BlipSong*)songToInsert;
- (BOOL)isConnectedToNetwork;
- (BOOL)isConnectedToWifi;
@end

@implementation AudioManager

@synthesize streamer;
@synthesize playlist;
@synthesize currentSong;
@synthesize searchTerms;
@synthesize songs;
@synthesize songIndexOfPlaylistCurrentlyPlaying;
@synthesize numberOfSongsPlayedTodayOnCellNetwork;

SYNTHESIZE_SINGLETON_FOR_CLASS(AudioManager);

- (void) startStreamerWithSong:(BlipSong*)song {
	
	if ([self isConnectedToNetwork]) {
		if (![self isConnectedToWifi]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boombox" 
															message:@"Due to bandwidth limitations, you may only listen to music while on wifi.  However, Search is not limited to wifi."
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
		
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
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boombox" 
														message:@"You are not connected to a network.  Please connect then try to play the song again."
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
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

- (BOOL) isConnectedToNetwork {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return appDelegate.remoteHostStatus != NotReachable;
}

- (BOOL) isConnectedToWifi {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return appDelegate.remoteHostStatus == ReachableViaWiFiNetwork;
}

// only used for cell network song limitations
- (void) incrementCellNetworkSongsPlayed {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	if (appDelegate.remoteHostStatus == ReachableViaCarrierDataNetwork) {
		self.numberOfSongsPlayedTodayOnCellNetwork++;
		NSLog(@"songs played on cell network today: %d", self.numberOfSongsPlayedTodayOnCellNetwork);
	}
}

// only used for cell network song limitations
- (BOOL) userHasReachedMaximumSongsForTheDay {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return (appDelegate.remoteHostStatus == ReachableViaCarrierDataNetwork && self.numberOfSongsPlayedTodayOnCellNetwork >= MAX_SONGS_FOR_CELL_NETWORK_PER_DAY);
}

@end