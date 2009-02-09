//
//  TopSearchViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 1/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TopSearchViewController.h"
#import "TouchXML.h"
#import "SearchViewController.h"
#import "Mobclix.h"

@implementation TopSearchViewController

@synthesize theTableView, topSearches, searchCell;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// this should be it's own function, but it's late and I don't feel like doing it
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSError *theError = NULL;
	CXMLDocument *theXMLDocument = [[[CXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.literalshore.com/gorloch/blip/cache/topsearches.xml"] options:0 error:&theError] autorelease];
	NSLog(@"finished getting the xml doc");
	NSArray *theNodes = NULL;
	
	theNodes = [theXMLDocument nodesForXPath:@"//searches/search" error:&theError];
	topSearches = [[NSMutableArray alloc] initWithCapacity:10];
	for (CXMLElement *theElement in theNodes) {
		theNodes = [theElement nodesForXPath:@"./search_term" error:NULL];
		[topSearches addObject:[[theNodes objectAtIndex:0] stringValue]];
	}
	[theTableView reloadData];
	[pool release];
	
	// mobclix test
	[Mobclix logEventWithLevel: LOG_LEVEL_INFO
				   processName: @"TopSearchViewController"
					 eventName: @"viewDidLoad"
				   description: @"someone is viewing the top searches" 
				appleFramework: FW_UI_KIT
						  stop: NO
	]; 
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[theTableView release];
	[topSearches release];
	[searchCell release];
	
    [super dealloc];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//NSLog(@"number of rows returned: %d", [audioManager.songs count]);
	return [topSearches count];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"MyIdentifier";
	
	TopSearchTableCellView *cell = (TopSearchTableCellView *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		
		UIViewController *vc = [[UIViewController alloc] initWithNibName:@"TopSearchCell" bundle:nil];
		cell = (TopSearchTableCellView *) vc.view;
		[vc release];
	}

	cell.artistLabel.text = [[topSearches objectAtIndex:indexPath.row] capitalizedString];

	return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	SearchViewController *parentController = self.parentViewController;
	parentController.blipSearchBar.text = [topSearches objectAtIndex:indexPath.row];
	[parentController searchBarSearchButtonClicked:parentController.blipSearchBar];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Button functions

- (IBAction)dismissModalView:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

@end
