//
//  AbstractAdViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 8/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADAdViewController.h"
//#import "MobclixAds.h"
#import "AudioManager.h"

//@interface AbstractAdViewController : UIViewController  <GADAdViewControllerDelegate, MobclixAdViewDelegate> {
@interface AbstractAdViewController : UIViewController  <GADAdViewControllerDelegate> {
    GADAdViewController *adViewController_;
    NSString *adwords;
	AudioManager *audioManager;
}

-(void)createGoogleAd;
-(void)createMobclixAd;
-(NSInteger)adToDisplay;

@end
