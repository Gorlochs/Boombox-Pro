//
//  PlaylistViewController.h
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/2/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *theTableView;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;

- (IBAction)removeModalView:(id)sender;

@end
