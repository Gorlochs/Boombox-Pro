//
//  BuyTableCellView.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/13/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "BuyTableCellView.h"


@implementation BuyTableCellView

@synthesize artistLabel;
@synthesize songTitleLabel;
@synthesize albumLabel;
@synthesize priceLabel;
@synthesize buyButton;
@synthesize songLocation;
@synthesize albumImage;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		songTitleLabel.font = [UIFont systemFontOfSize:26.0];
		albumLabel.font = [UIFont systemFontOfSize:12.0];
		[songTitleLabel setHighlightedTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    }
    return self;
}

- (void)setBuyInfo:(NSMutableDictionary*)songInfo {
	artistLabel.text = [songInfo objectForKey:@"artistName"];
	songTitleLabel.text = [songInfo objectForKey:@"trackName"];
	if ([[songInfo objectForKey:@"collectionName"] isMemberOfClass:[NSNull class]]) {
		albumLabel.text = @"";
	} else {
		albumLabel.text = [NSString stringWithFormat:@"%@ - %@", [[songInfo objectForKey:@"artistName"] uppercaseString], [songInfo objectForKey:@"collectionName"]];
	}
	priceLabel.text = [[NSString stringWithFormat:@"$%f", [[songInfo objectForKey:@"trackPrice"] floatValue]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0"]];
	
	// display image
//	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[songInfo objectForKey:@"artworkUrl60"]]];
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[songInfo objectForKey:@"artworkUrl60"]] options:NSMappedRead error:nil];
	UIImage *tmpImg = [[UIImage alloc] initWithData:data];
	albumImage.image = tmpImg;
	[tmpImg release];
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
	[albumImage release];
	
    [super dealloc];
}


@end
