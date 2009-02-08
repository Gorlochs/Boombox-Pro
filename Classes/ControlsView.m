//
//  ControlsView.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/3/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "ControlsView.h"


@implementation ControlsView

@synthesize playButton, nextButton, previousButton;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[playButton release];
    [super dealloc];
}


@end
