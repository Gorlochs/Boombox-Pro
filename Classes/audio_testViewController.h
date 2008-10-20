//
//  audio_testViewController.h
//  audio-test
//
//  Created by Shawn Bernard on 10/19/08.
//  Copyright Nau Inc. 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface audio_testViewController : UIViewController {
	IBOutlet UIButton *audioButton;
	AudioStreamer *streamer;
}
@property (nonatomic, retain) IBOutlet UIButton *audioButton;

- (IBAction)playAudio:(id)sender;

@end

