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
		//self.backgroundColor = [UIColor redColor];
		//[playButton addTarget:self action:@selector(playSong:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (NSString*)songLocation {
	return [songLocation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setCellData:(BlipSong*)mySong {
	self.song = mySong;
	artistLabel.text = song.artist;
	songTitleLabel.text = song.title;
	songLocation = song.location;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}

//- (void)playSong {
//	NSString *streamUrl = [songLocation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//	NSLog(@"chosen stream: %@", streamUrl);
//	NSURL *url = [NSURL URLWithString:streamUrl];
//	
//	if (((BoomboxViewController*) self.parentViewController).streamer) {
//		[((BoomboxViewController*) self.parentViewController).streamer stop];
//	}
//	((BoomboxViewController*) self.parentViewController).streamer = [[AudioStreamer alloc] initWithURL:url];
//	[((BoomboxViewController*) self.parentViewController).streamer addObserver:self.parentViewController forKeyPath:@"isPlaying" options:0 context:nil];
//	[((BoomboxViewController*) self.parentViewController).streamer start];
//}

@end