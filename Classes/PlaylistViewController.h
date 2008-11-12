//
//  PlaylistViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/2/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdMobDelegateProtocol.h";


@interface PlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AdMobDelegate> {
	UITableView *theTableView;
	
	// AdMob code  
	AdMobView *adMobAd;  // the actual ad; self.view is a placeholder to indicate where the ad should be placed; intentially _not_ an IBOutlet
	NSTimer *autoslider; // timer to slide in fresh ads
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet AdMobView *adMobAd;

- (IBAction)removeModalView:(id)sender;
- (IBAction)playSong:(id)sender;
- (void)refreshAd:(NSTimer *)timer;

@end
