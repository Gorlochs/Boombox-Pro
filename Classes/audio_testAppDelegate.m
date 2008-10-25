//
//  audio_testAppDelegate.m
//  audio-test
//
//  Created by Shawn Bernard on 10/19/08.
//  Copyright Nau Inc. 2008. All rights reserved.
//

#import "audio_testAppDelegate.h"
#import "audio_testViewController.h"

@implementation audio_testAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
