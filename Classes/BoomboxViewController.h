//
//  BoomboxViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/3/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlsView.h"
#import "SpeakerView.h"
#import "SearchViewController.h"
#import "PlaylistViewController.h"
#import "AudioStreamer.h"

@class AudioStreamer;

@interface BoomboxViewController : UIViewController {
	AudioStreamer *streamer;
	
	ControlsView *controlsView;
	SpeakerView *speakerView;
	UILabel *songLabel;
	
	SearchViewController *searchViewController;
	PlaylistViewController *playlistController;
}

@property (nonatomic, retain) IBOutlet ControlsView *controlsView;
@property (nonatomic, retain) IBOutlet SpeakerView *speakerView;
@property (nonatomic, retain) IBOutlet UILabel *songLabel;
@property (nonatomic, retain) AudioStreamer *streamer;

- (IBAction)playAction:(id)sender;
- (IBAction)displaySearchViewAction:(id)sender;
- (IBAction)displayPlaylistViewAction:(id)sender;
- (IBAction)stopStream;

@end
