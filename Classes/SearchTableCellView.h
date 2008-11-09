//
//  SearchTableCellView.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/8/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlipSong.h"

@interface SearchTableCellView : UITableViewCell {
	UILabel *artistLabel;
	UILabel *songTitleLabel;
	UIButton *playButton;
	UIButton *addToPlaylistButton;
	UIButton *buyButton;
	NSString *songLocation;
	BlipSong *song;
}

@property (nonatomic, retain) IBOutlet UILabel *artistLabel;
@property (nonatomic, retain) IBOutlet UILabel *songTitleLabel;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *addToPlaylistButton;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) NSString *songLocation;
@property (nonatomic, retain) BlipSong *song;

- (void)setCellData:(BlipSong*)song;

@end
