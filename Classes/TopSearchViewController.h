//
//  TopSearchViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 1/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TopSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *theTableView;
	NSMutableArray *topSearches;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) NSMutableArray *topSearches;

-(IBAction)dismissModalView:(id)sender;

@end
