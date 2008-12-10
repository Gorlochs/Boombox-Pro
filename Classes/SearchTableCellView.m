//
//  SearchTableCellView.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/8/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
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
		[songTitleLabel setHighlightedTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
    }
    return self;
}

- (NSString*)songLocation {
	return [songLocation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setCellData:(BlipSong*)mySong {
	songTitleLabel.font = [UIFont systemFontOfSize:18.0];
	artistLabel.font = [UIFont systemFontOfSize:12.0];
	
	self.song = mySong;
	artistLabel.text = [song.artist uppercaseString];
	songTitleLabel.text = song.title;
	songLocation = song.location;
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
