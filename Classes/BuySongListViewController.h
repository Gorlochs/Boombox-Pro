//
//  BuySongListViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/13/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BuySongListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *theTableView;
	
	NSMutableArray *searchResults;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) NSMutableArray *searchResults;

-(IBAction)dismissModalView:(id)sender;
-(void) getItunesSearchResults;

@end
