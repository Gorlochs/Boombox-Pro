//
//  iPhoneStreamingPlayerAppDelegate.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoomboxViewController.h"
#import <sqlite3.h>


@class SearchViewController;

@interface iPhoneStreamingPlayerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	BoomboxViewController *viewController;
	sqlite3 *database;
	
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
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSMutableArray *playlist;
@property NSInteger songIndexOfPlaylistCurrentlyPlaying;
@property (nonatomic, retain) BlipSong *currentSong;
@property (nonatomic, retain) NSString *searchTerms;
@property (nonatomic, retain) NSMutableArray *songs;
@property (nonatomic, retain) IBOutlet BoomboxViewController *viewController;

@end

