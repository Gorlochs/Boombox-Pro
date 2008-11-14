//
//  BuyTableCellView.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/13/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import "BuyTableCellView.h"


@implementation BuyTableCellView

@synthesize artistLabel;
@synthesize songTitleLabel;
@synthesize albumLabel;
@synthesize priceLabel;
@synthesize buyButton;
@synthesize songLocation;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)setBuyInfo:(NSMutableDictionary*)songInfo {
	artistLabel.text = [songInfo objectForKey:@"artistName"];
	songTitleLabel.text = [songInfo objectForKey:@"trackName"];
	albumLabel.text = [songInfo objectForKey:@"collectionName"];
	priceLabel.text = [[NSString stringWithFormat:@"$%f", [[songInfo objectForKey:@"trackPrice"] floatValue]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0"]];
	
	NSLog(@"trackPrice class: %@", [[songInfo objectForKey:@"trackPrice"] class]);
	NSLog(@"trackPrice: %f", [[songInfo objectForKey:@"trackPrice"] floatValue]);
	NSLog(@"songInfo: %@", songInfo);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[artistLabel release];
	[songTitleLabel release];
	[albumLabel release];
	[priceLabel release];
	[buyButton release];
	[songLocation release];
	
    [super dealloc];
}


@end
