//
//  SearchTableCellView.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/8/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "SearchTableCellView.h"
#import "BlipSong.h"
#import "BoomboxViewController.h"

@implementation SearchTableCellView

@synthesize artistLabel;
@synthesize songTitleLabel;
@synthesize playButton;
@synthesize addToPlaylistButton;
@synthesize buyButton;
@synthesize songLocation;
@synthesize song;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)setCellData:(BlipSong*)mySong {
	// this doesn't seem to work anywhere else, like initWithFrame :(
	[songTitleLabel setHighlightedTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
	
	songTitleLabel.font = [UIFont systemFontOfSize:18.0];
	artistLabel.font = [UIFont systemFontOfSize:12.0];
	
	self.song = mySong;
	artistLabel.text = [song.artist uppercaseString];
    songLocation = [NSString stringWithString:song.location];
	songTitleLabel.text = song.title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
	[artistLabel release];
	[songTitleLabel release];
	[playButton release];
	[addToPlaylistButton release];
	[buyButton release];
	[songLocation release];
	[song release];
	
    [super dealloc];
}

@end
