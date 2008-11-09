//
//  SearchTableCellView.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/8/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import "SearchTableCellView.h"
#import "BlipSong.h"

@implementation SearchTableCellView

@synthesize artistLabel;
@synthesize songTitleLabel;
@synthesize playButton;
@synthesize addToPlaylistButton;
@synthesize buyButton;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.backgroundColor = [UIColor redColor];
    }
    return self;
}


- (void)setCellData:(BlipSong*)song {
	artistLabel.text = song.artist;
	songTitleLabel.text = song.title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
