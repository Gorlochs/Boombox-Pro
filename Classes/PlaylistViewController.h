//
//  PlaylistViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/2/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#define AD_REFRESH_PERIOD 60.0 // display fresh ads once per minute

#import <UIKit/UIKit.h>
#import "SearchTableCellView.h"
#import "AudioManager.h"
#import "MobclixAds.h"

@interface PlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	
	UITableView *theTableView;
	UIView *buttonView;
	UIButton *myPlaylistButton;
	UIButton *popularPlaylistsButton;
	SearchTableCellView *tableCell;
	
	AudioManager *audioManager;
	
	// Mobclix ad
	MMABannerXLAdView *mobclixAdView;
}

@property (nonatomic, retain) IBOutlet UIView *buttonView;
@property (nonatomic, retain) IBOutlet UIButton *myPlaylistButton;
@property (nonatomic, retain) IBOutlet UIButton *popularPlaylistsButton;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) SearchTableCellView *tableCell;
@property (nonatomic, retain) IBOutlet MMABannerXLAdView *mobclixAdView;

- (IBAction)removeModalView:(id)sender;
- (IBAction)playSong:(id)sender;
- (IBAction)displayPopularPlaylist;
- (IBAction)displayMyPlaylist;

@end
