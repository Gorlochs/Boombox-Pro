//
//  TopSearchViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 1/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopSearchTableCellView.h"


@interface TopSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *theTableView;
	NSMutableArray *topSearches;
	
	TopSearchTableCellView *searchCell;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) NSMutableArray *topSearches;
@property (nonatomic, retain) TopSearchTableCellView *searchCell;

-(IBAction)dismissModalView:(id)sender;

@end
