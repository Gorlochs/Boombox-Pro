//
//  BlipSearchViewController.h
//  audio-test
//
//  Created by Shawn Bernard on 10/20/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BlipSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UISearchBar *searchBar;
	IBOutlet UITableView *theTableView;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

-(IBAction)searchBlip:(id)sender;

@end
