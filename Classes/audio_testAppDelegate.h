//
//  audio_testAppDelegate.h
//  audio-test
//
//  Created by Shawn Bernard on 10/19/08.
//  Copyright Nau Inc. 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class audio_testViewController;

@interface audio_testAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	audio_testViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet audio_testViewController *viewController;

@end

