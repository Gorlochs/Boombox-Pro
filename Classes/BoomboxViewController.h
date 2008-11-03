//
//  BoomboxViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/3/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlsView.h"

@interface BoomboxViewController : UIViewController {
	ControlsView *controlsView;
}

@property (nonatomic, retain) IBOutlet ControlsView *controlsView;

@end
