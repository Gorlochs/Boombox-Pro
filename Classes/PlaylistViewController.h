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
#import "BuySongListViewController.h"
#import "AdMobDelegateProtocol.h"
#import "GADAdViewController.h"

@interface PlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AdMobDelegate, GADAdViewControllerDelegate> {
	
	UITableView *theTableView;
	UIView *buttonView;
	UIButton *myPlaylistButton;
	UIButton *popularPlaylistsButton;
	SearchTableCellView *tableCell;
	BuySongListViewController *buySongListController;
	
	AudioManager *audioManager;
    
    // AdMob code
    NSTimer *autoslider; // timer to slide in fresh ads
    AdMobView *adMobAd;
    
    GADAdViewController *adViewController_;
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
- (void)refreshAd:(NSTimer *)timer;

@end
