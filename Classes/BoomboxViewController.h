//
//  BoomboxViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/3/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ControlsView.h"
#import "EqualizerView.h"
#import "SearchViewController.h"
#import "PlaylistViewController.h"
#import "BuySongListViewController.h"
#import "AudioStreamer.h"
#import "SingleSpeakerView.h"
#import "AudioManager.h"
#import "TopButtonView.h"

@interface BoomboxViewController : UIViewController {
	AudioManager *audioManager;
	
	ControlsView *controlsView;
	EqualizerView *equalizerView;
	IBOutlet UIImageView *equalizerAnimationView;
	SingleSpeakerView *leftSpeakerView;
	SingleSpeakerView *rightSpeakerView;
	TopButtonView *topButtonView;
	
	UILabel *songLabel;
	
	SearchViewController *searchViewController;
	PlaylistViewController *playlistController;
	BuySongListViewController *buySongListController;
	
    NSMutableArray *images;
    NSMutableArray *speakerImages;
    BOOL _isPlaying;
}

@property (nonatomic, retain) IBOutlet ControlsView *controlsView;
@property (nonatomic, retain) IBOutlet SingleSpeakerView *leftSpeakerView;
@property (nonatomic, retain) IBOutlet SingleSpeakerView *rightSpeakerView;
@property (nonatomic, retain) IBOutlet EqualizerView *equalizerView;
@property (nonatomic, retain) IBOutlet TopButtonView *topButtonView;
@property (nonatomic, retain) IBOutlet UILabel *songLabel;
@property (nonatomic, retain, readonly) AudioManager *audioManager;

- (IBAction)playAction:(id)sender;
- (IBAction)displaySearchViewAction:(id)sender;
- (IBAction)displayPlaylistViewAction:(id)sender;
- (IBAction)displayBuyViewAction:(id)sender;
- (IBAction)stopStream;
- (IBAction)playNextSongInPlaylist;
- (IBAction)playPreviousSongInPlaylist;
- (CAKeyframeAnimation*)imagesAnimation;

@end
