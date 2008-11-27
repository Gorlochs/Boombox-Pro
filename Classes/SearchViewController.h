//
//  SearchViewController.h
//  SearchViewController
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#define AD_REFRESH_PERIOD 60.0 // display fresh ads once per minute

#import <UIKit/UIKit.h>
#import "BlipSong.h"
#import "AdMobDelegateProtocol.h";
#import "BuySongListViewController.h"
#import "AudioManager.h"

@class AudioStreamer, SearchTableCellView, AdMobView;

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, AdMobDelegate>
{
	AudioStreamer *streamer;
	
	IBOutlet UISearchBar *blipSearchBar;
	IBOutlet UITableView *theTableView;
	SearchTableCellView *searchCell;
	BuySongListViewController *buySongListController;
	
	AudioManager *audioManager;
	
	NSXMLParser *rssParser;
	
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	BlipSong *item;
	
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString *currentElement;
	NSMutableString *currentTitle, *currentLocation, *currentArtist;
	
	// AdMob code  
	AdMobView *adMobAd;  // the actual ad; self.view is a placeholder to indicate where the ad should be placed; intentially _not_ an IBOutlet
	NSTimer *autoslider; // timer to slide in fresh ads

}

@property (nonatomic, retain) IBOutlet UISearchBar *blipSearchBar;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) SearchTableCellView *searchCell;
@property (nonatomic, retain) IBOutlet AdMobView *adMobAd;

- (void)parseXMLFileAtURL:(NSString *)URL;
- (IBAction)removeModalView:(id)sender;
- (void)refreshAd:(NSTimer *)timer;

@end

