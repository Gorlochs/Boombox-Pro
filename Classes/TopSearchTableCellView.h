//
//  TopSearchTableCellView.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 2/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TopSearchTableCellView : UITableViewCell {
	UILabel *artistLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *artistLabel;

@end
