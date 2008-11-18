//
//  BoomboxViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/3/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
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

@class AudioStreamer;

@interface BoomboxViewController : UIViewController {
	AudioStreamer *streamer;
	
	ControlsView *controlsView;
	EqualizerView *equalizerView;
	SingleSpeakerView *leftSpeakerView;
	SingleSpeakerView *rightSpeakerView;
	
	UILabel *songLabel;
	
	SearchViewController *searchViewController;
	PlaylistViewController *playlistController;
	BuySongListViewController *buySongListController;
	
    NSMutableArray *images;
    NSMutableArray *speakerImages;
}

@property (nonatomic, retain) IBOutlet ControlsView *controlsView;
@property (nonatomic, retain) IBOutlet SingleSpeakerView *leftSpeakerView;
@property (nonatomic, retain) IBOutlet SingleSpeakerView *rightSpeakerView;
@property (nonatomic, retain) IBOutlet EqualizerView *equalizerView;
@property (nonatomic, retain) IBOutlet UILabel *songLabel;
@property (nonatomic, retain) AudioStreamer *streamer;

- (IBAction)playAction:(id)sender;
- (IBAction)displaySearchViewAction:(id)sender;
- (IBAction)displayPlaylistViewAction:(id)sender;
- (IBAction)displayBuyViewAction:(id)sender;
- (IBAction)stopStream;
- (CAKeyframeAnimation*)imagesAnimation;

@end
