//
//  BuyTableCellView.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/13/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BuyTableCellView : UITableViewCell {
	UILabel *artistLabel;
	UILabel *songTitleLabel;
	UILabel *albumLabel;
	UILabel *priceLabel;
	UIButton *buyButton;
	NSString *songLocation;
	UIImageView *albumImage;
}

@property (nonatomic, retain) IBOutlet UILabel *artistLabel;
@property (nonatomic, retain) IBOutlet UILabel *songTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *albumLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) IBOutlet UIImageView *albumImage;
@property (nonatomic, retain) NSString *songLocation;

- (void)setBuyInfo:(NSMutableDictionary*)songInfo;

@end
