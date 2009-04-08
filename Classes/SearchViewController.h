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
#import "AdMobDelegateProtocol.h"
#import "GADAdViewController.h"

@class AudioStreamer, SearchTableCellView, AdMobView;

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, AdMobDelegate, GADAdViewControllerDelegate>
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
    
    // AdMob code
    NSTimer *autoslider; // timer to slide in fresh ads
    AdMobView *adMobAd;
    
    GADAdViewController *adViewController_;
}

@property (nonatomic, retain) IBOutlet UISearchBar *blipSearchBar;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) SearchTableCellView *searchCell;
@property (nonatomic, retain) IBOutlet AdMobView *adMobAd;

- (IBAction)removeModalView:(id)sender;
- (IBAction)displayTopSearchesViewAction:(id)sender;
- (void)refreshAd:(NSTimer *)timer;

@end

