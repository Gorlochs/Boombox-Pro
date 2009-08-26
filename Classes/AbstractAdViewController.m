//
//  AbstractAdViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 8/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AbstractAdViewController.h"
#import "iPhoneStreamingPlayerAppDelegate.h"

@implementation AbstractAdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		audioManager = [AudioManager sharedAudioManager];
        @try {
            adwords = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.literalshore.com/gorloch/blip/adwords.txt"] 
                                               encoding:NSASCIIStringEncoding 
                                                  error:nil];
        }
        @catch (NSException * e) {
            NSLog(@"error retrieving adwords");
            adwords = @"";
        }
        
        NSLog(@"adwords in the initWithNibName: %@", adwords);
	}
	return self;
}

- (void) createGoogleAd {
    adViewController_ = [[GADAdViewController alloc] initWithDelegate:self];
    adViewController_.adSize = kGADAdSize320x50;
    
    if (adwords == nil || [adwords isEqualToString:@""]) {
        adwords = [NSString stringWithString:@"music+downloads,free+music,downloads,free+downloads"];
    }
    NSNumber *channel = [NSNumber numberWithUnsignedLongLong:2638511974];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"ca-pub-4358000644319833", kGADAdSenseClientID,
                                [adwords stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], kGADAdSenseKeywords,
                                [NSArray arrayWithObjects:channel, nil], kGADAdSenseChannelIDs,
                                [NSNumber numberWithInt:0], kGADAdSenseIsTestAdRequest,
                                nil];
    [adViewController_ loadGoogleAd:attributes];
    
    // Position ad at bottom of screen
    //CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect rect = adViewController_.view.frame;
    rect.origin = CGPointMake(80,250);
    adViewController_.view.frame = rect;
    [self.view addSubview:adViewController_.view];
}

- (void) createMobclixAd {
    MMABannerXLAdView* bannerAdView = [MMABannerXLAdView new];
    bannerAdView.center = CGPointMake(240,276);
    bannerAdView.delegate = self; //Optional
    [self.view addSubview:bannerAdView];
    [bannerAdView release];
    
    // Get a single advertisement once.
    [bannerAdView getAd];
}

- (NSInteger) adToDisplay {
	iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
    return appDelegate.adType;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [adViewController_ release];
    [adwords release];
    [super dealloc];
}


@end
