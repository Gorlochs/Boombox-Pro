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
#import "TouchXML.h"

#define MAX_SONGS_FOR_CELL_NETWORK_PER_DAY 15

@interface AudioManager (Private)
- (void)insertSongIntoDB:(BlipSong*)songToInsert;
- (BOOL)isConnectedToNetwork;
- (BOOL)isConnectedToWifi;
- (void)populateTopSongs;
@end

@implementation AudioManager

@synthesize streamer;
@synthesize playlist;
@synthesize currentSong;
@synthesize searchTerms;
@synthesize songs;
@synthesize topSongs;
@synthesize songIndexOfPlaylistCurrentlyPlaying;
@synthesize numberOfSongsPlayedTodayOnCellNetwork;

SYNTHESIZE_SINGLETON_FOR_CLASS(AudioManager);

- (void) startStreamerWithSong:(BlipSong*)song {
	
	if ([self isConnectedToNetwork]) {
//		if (![self isConnectedToWifi]) {
//			NSLog(@"*** device is NOT connected to wifi ***");
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boombox" 
//															message:@"In order to play songs, please connect to a WiFi network. You may still search and add songs to your playlist."
//														   delegate:self 
//												  cancelButtonTitle:@"OK" 
//												  otherButtonTitles:nil];
//			[alert show];
//			[alert release];
//			return;
//		} else {
			// just in case a stream is playing, stop the stream before starting a new one
			[streamer stop];
			
			// start the stream
			NSURL *url = [NSURL URLWithString:[[song location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			streamer = [[AudioStreamer alloc] initWithURL:url];
			[streamer start];
			
			// insert song into DB
			[self insertSongIntoDB:song];
			
			// set currentSong
			self.currentSong = song;
			
			// set currently playing song to -1 (if this is a playlist song, the playlist function will set it correctly)
			self.songIndexOfPlaylistCurrentlyPlaying = -1;
			
			// start the network indicator
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//		}
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boombox" 
														message:@"You are not connected to a network. Please connect to a network and then try to play the song again."
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) startStreamerWithPlaylistIndex:(NSInteger)playListIndex {
	// find song to play
	BlipSong *songToPlay = [[self retrieveCurrentSongList] objectAtIndex:playListIndex];

//	NSLog(@"checking song url");
//	NSURL *tmpurl = [NSURL URLWithString:songToPlay.location];
//	NSLog(@"tmpurl: %@", tmpurl);
//	if (tmpurl == nil || tmpurl == NULL) {
//		[self playNextSongInPlaylist];
//	}
	
	// set currentSong
	self.currentSong = songToPlay;
	
	// start stream
	[self startStreamerWithSong:songToPlay];
	
	// set currently playing index correctly
	self.songIndexOfPlaylistCurrentlyPlaying = playListIndex;
	NSLog(@"AudioManager: current song index playing is: %d", self.songIndexOfPlaylistCurrentlyPlaying);
}

- (void) playNextSongInPlaylist {
	[self startStreamerWithPlaylistIndex:++self.songIndexOfPlaylistCurrentlyPlaying];
}

- (void) playPreviousSongInPlaylist {
	[self startStreamerWithPlaylistIndex:--self.songIndexOfPlaylistCurrentlyPlaying];
}

- (void) stopStreamer {
	NSLog(@"AudioManager.stopStreamer is being called.  songIndex is being set to -1");
	// if streamer is stopped, then reset the currently playing index
	songIndexOfPlaylistCurrentlyPlaying = -1;

	// the current song is now nil, since there is no song playing
	self.currentSong = nil;
	
	// stop the streamer
	[streamer stop];
	
	// switch off the network activity indicator in the status bar
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL) isSongPlaying:(BlipSong*)song {
    if (song == NULL || [song location] == NULL || streamer == NULL || ![streamer isPlaying]) {
        return NO;
    }
	return [[song location] isEqualToString:[[streamer getUrl] absoluteString]];
}

// only used for cell network song limitations
- (void) incrementCellNetworkSongsPlayed {
	iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
	if (appDelegate.remoteHostStatus == ReachableViaCarrierDataNetwork) {
		self.numberOfSongsPlayedTodayOnCellNetwork++;
		NSLog(@"songs played on cell network today: %d", self.numberOfSongsPlayedTodayOnCellNetwork);
	}
}

// only used for cell network song limitations
- (BOOL) userHasReachedMaximumSongsForTheDay {
	iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
	return (appDelegate.remoteHostStatus == ReachableViaCarrierDataNetwork && self.numberOfSongsPlayedTodayOnCellNetwork >= MAX_SONGS_FOR_CELL_NETWORK_PER_DAY);
}

- (NSMutableArray*) retrieveTopSongs {
	if (self.topSongs == NULL) {
		[self populateTopSongs];
	}
	return self.topSongs;
}

- (void)switchToPlaylistMode:(PlaylistMode*)pmode {
	playlistMode = pmode;
}

- (PlaylistMode*)determinePlaylistMode {
	if (playlistMode == NULL) {
		playlistMode = mine;
	}
	return playlistMode;
}

- (NSArray*)retrieveCurrentSongList {
	if ([self determinePlaylistMode] == mine) {
		return self.playlist;
	} else if ([self determinePlaylistMode] == popular) {
		return self.topSongs;
	} else {
		return self.playlist;
	}
}

#pragma mark Private Functions

- (void) populateTopSongs {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSError *theError = NULL;
	CXMLDocument *theXMLDocument = [[[CXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.literalshore.com/gorloch/blip/cache/topsongs.xml"] options:0 error:&theError] autorelease];
	NSLog(@"finished getting the topsongs xml doc");
	NSArray *theNodes = NULL;
	
	theNodes = [theXMLDocument nodesForXPath:@"//songs/song" error:&theError];
	topSongs = [[NSMutableArray alloc] initWithCapacity:20];
	for (CXMLElement *theElement in theNodes) {
		NSLog(@"song: %@", theElement);
		
		NSURL *tmpurl = [NSURL URLWithString:[[[theElement nodesForXPath:@"./location" error:NULL] objectAtIndex:0] stringValue]];
		NSLog(@"tmpurl: %@", tmpurl);
		if (tmpurl != NULL) {
			BlipSong *tempSong = [[BlipSong alloc] init];
			tempSong.title = [[[theElement nodesForXPath:@"./song_name" error:NULL] objectAtIndex:0] stringValue];
			tempSong.artist = [[[theElement nodesForXPath:@"./artist" error:NULL] objectAtIndex:0] stringValue];
			tempSong.location = [[[theElement nodesForXPath:@"./location" error:NULL] objectAtIndex:0] stringValue];
			//theNodes = [theElement nodesForXPath:@"./song_name" error:NULL];
			[topSongs addObject:tempSong];
			[tempSong release];
		}
	}
	NSLog(@"top songs: %@", topSongs);
	//[theTableView reloadData];
	[pool release];
}

- (BOOL) isConnectedToNetwork {
	iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
	return appDelegate.remoteHostStatus != NotReachable;
}

- (BOOL) isConnectedToWifi {
	iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
	return appDelegate.remoteHostStatus == ReachableViaWiFiNetwork;
}

- (void)insertSongIntoDB:(BlipSong*)songToInsert {
	iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
	NSURL *insertUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://literalshore.com/gorloch/blip/insert-1.1.1.php?song=%@&artist=%@&songUrl=%@&cc=%@&gkey=g0rl0ch1an5", 
											 [[songToInsert.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
											 [[songToInsert.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
											 [[songToInsert.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
											 [appDelegate getCountryCode]]];
	
	NSLog(@"insert url: %@", insertUrl);
	NSString *insertResult = [NSString stringWithContentsOfURL:insertUrl];
	NSLog(@"AM insert result: %@", insertResult);
}

@end
