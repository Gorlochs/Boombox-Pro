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

#define GOOGLE_AD_DISPLAY 0
#define MOBCLIX_AD_DISPLAY 1
#define HALF_AND_HALF_AD_DISPLAY 2
#define IAD_AD_DISPLAY 3

#ifdef DEBUG
#   define DLog(__FORMAT__, ...) NSLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...) do {} while (0)
#endif

@class SearchViewController;

@interface iPhoneStreamingPlayerAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow *window;
	BoomboxViewController *viewController;
	sqlite3 *database;
	
	AudioManager *audioManager;
	
	NetworkStatus remoteHostStatus;
        
    NSInteger adType;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BoomboxViewController *viewController;
@property NetworkStatus remoteHostStatus;
@property (nonatomic) NSInteger adType;

- (NSString*) getCountryCode;
- (void) setAdTypeToDisplay;

@end

