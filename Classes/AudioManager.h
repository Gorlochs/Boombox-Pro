//
//  AudioManager.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"
#import "BlipSong.h"

@interface AudioManager : NSObject {
	AudioStreamer *streamer;
	
	// the user's compiled playlist of songs
	NSMutableArray *playlist;
	
	// the index of the song in the playlist that is currently being played
	NSInteger songIndexOfPlaylistCurrentlyPlaying;
	
	// the song currently playing
	BlipSong *currentSong;
	
	// search string that the user enters
	NSString *searchTerms;
	
	// the list of songs returned from a search
	NSMutableArray *songs;
	
	NSInteger numberOfSongsPlayedTodayOnCellNetwork;
}

@property (nonatomic, retain) AudioStreamer *streamer;
@property (nonatomic, retain) NSMutableArray *playlist;
@property NSInteger songIndexOfPlaylistCurrentlyPlaying;
@property (nonatomic, retain) BlipSong *currentSong;
@property (nonatomic, retain) NSString *searchTerms;
@property (nonatomic, retain) NSMutableArray *songs;
@property NSInteger numberOfSongsPlayedTodayOnCellNetwork;

+ (AudioManager*) sharedAudioManager;
- (void) startStreamerWithSong:(BlipSong*)song;
- (void) stopStreamer;
- (void) insertSongIntoDB:(BlipSong*)songToInsert;
- (BOOL) isSongPlaying:(BlipSong*)song;
- (void) startStreamerWithPlaylistIndex:(NSInteger)playListIndex;
- (void) incrementCellNetworkSongsPlayed;
- (BOOL) userHasReachedMaximumSongsForTheDay;
- (void) playNextSongInPlaylist;
- (void) playPreviousSongInPlaylist;
@end
