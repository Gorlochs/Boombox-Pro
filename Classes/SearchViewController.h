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
#import "BuySongListViewController.h"
#import "AudioManager.h"
#import "TopSearchViewController.h"
#import "GADAdViewController.h"

@class AudioStreamer, SearchTableCellView;

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, GADAdViewControllerDelegate>
{
	IBOutlet UISearchBar *blipSearchBar;
	IBOutlet UITableView *theTableView;
	SearchTableCellView *searchCell;
	BuySongListViewController *buySongListController;
	TopSearchViewController *topSearchViewController;
	
	AudioManager *audioManager;
	
	NSXMLParser *rssParser;
	
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	BlipSong *item;
	
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString *currentElement;
	NSMutableString *currentTitle, *currentLocation, *currentArtist;
    
    GADAdViewController *adViewController_;
//    NSDictionary *attributes;
//    NSNumber *channel;
}

@property (nonatomic, retain) IBOutlet UISearchBar *blipSearchBar;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) SearchTableCellView *searchCell;

- (IBAction)removeModalView:(id)sender;
- (IBAction)displayTopSearchesViewAction:(id)sender;

@end

