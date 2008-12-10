//
//  iPhoneStreamingPlayerAppDelegate.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoomboxViewController.h"
#import <sqlite3.h>
#import "AudioManager.h"
#import "Reachability.h"

@class SearchViewController;

@interface iPhoneStreamingPlayerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	BoomboxViewController *viewController;
	sqlite3 *database;
	
	AudioManager *audioManager;
	
	NetworkStatus remoteHostStatus;
	NetworkStatus internetConnectionStatus;
	NetworkStatus localWiFiConnectionStatus;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BoomboxViewController *viewController;
@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;

@end

