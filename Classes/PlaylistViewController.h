//
//  PlaylistViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/2/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#define AD_REFRESH_PERIOD 60.0 // display fresh ads once per minute

#import <UIKit/UIKit.h>
#import "AdMobDelegateProtocol.h"
#import "SearchTableCellView.h"
#import "AudioManager.h"

@interface PlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AdMobDelegate> {
	
	UITableView *theTableView;
	UIView *buttonView;
	UIButton *myPlaylistButton;
	UIButton *popularPlaylistsButton;
	SearchTableCellView *tableCell;
	
	AudioManager *audioManager;
	
	// AdMob code  
	AdMobView *adMobAd;  // the actual ad; self.view is a placeholder to indicate where the ad should be placed; intentially _not_ an IBOutlet
	NSTimer *autoslider; // timer to slide in fresh ads
}

@property (nonatomic, retain) IBOutlet UIView *buttonView;
@property (nonatomic, retain) IBOutlet UIButton *myPlaylistButton;
@property (nonatomic, retain) IBOutlet UIButton *popularPlaylistsButton;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) SearchTableCellView *tableCell;
@property (nonatomic, retain) IBOutlet AdMobView *adMobAd;

- (IBAction)removeModalView:(id)sender;
- (IBAction)playSong:(id)sender;
- (IBAction)displayPopularPlaylist;
- (IBAction)displayMyPlaylist;

// AdMob
- (void)refreshAd:(NSTimer *)timer;

@end
