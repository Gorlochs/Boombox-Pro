//
//  BuySongListViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/13/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyTableCellView.h"


@interface BuySongListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *theTableView;
	
	NSMutableArray *searchResults;
	
	BuyTableCellView *buyCell;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) BuyTableCellView *buyCell;

-(IBAction)dismissModalView:(id)sender;
-(void) getItunesSearchResults;

@end
