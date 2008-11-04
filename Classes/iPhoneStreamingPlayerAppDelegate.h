//
//  iPhoneStreamingPlayerAppDelegate.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoomboxViewController.h"

@class iPhoneStreamingPlayerViewController;

@interface iPhoneStreamingPlayerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	BoomboxViewController *viewController;
	
	NSMutableArray *playlist;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSMutableArray *playlist;
@property (nonatomic, retain) IBOutlet BoomboxViewController *viewController;

@end

