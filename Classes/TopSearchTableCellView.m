//
//  TopSearchTableCellView.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 2/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TopSearchTableCellView.h"


@implementation TopSearchTableCellView

@synthesize artistLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
