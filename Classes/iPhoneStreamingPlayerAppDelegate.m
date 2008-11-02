//
//  iPhoneStreamingPlayerAppDelegate.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "iPhoneStreamingPlayerAppDelegate.h"
#import "iPhoneStreamingPlayerViewController.h"

@implementation iPhoneStreamingPlayerAppDelegate

@synthesize window;
@synthesize playlist;
@synthesize tabBarController;

// keep track of playlist objects in the delegate:
//		(BOOL) isPlayingFromPlaylist
//		(NSMutableArray) playlist
//		(NSInteger) songIndexPlayingFromPlaylist
//
// maybe remove objects from playlist array?

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch
	[[NSBundle mainBundle] loadNibNamed:@"MainTabView" owner:self options:nil];
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}


@end
