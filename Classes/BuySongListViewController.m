//
//  BuySongListViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/13/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import "BuySongListViewController.h"
#import "BoomboxViewController.h"
#import "CJSONDeserializer.h"

@implementation BuySongListViewController

@synthesize theTableView;
@synthesize searchResults;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

- (void)viewDidLoad {
	[self getItunesSearchResults];
    [super viewDidLoad];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(IBAction)dismissModalView:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[theTableView release];
	
    [super dealloc];
}

#pragma mark TableView Delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	//NSLog(@"inside playlist table. playlist: %@", appDelegate.playlist);
    //return [appDelegate.playlist count];
	NSLog(@"total row count: %d", [searchResults count]);
	return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	if (self.searchResults) {
		//NSLog(@"results: %@", [searchResults objectAtIndex:1]);
//		NSLog(@"row: %d", indexPath.row);
		NSDictionary *obj = [self.searchResults objectAtIndex:indexPath.row];
		cell.text = [obj objectForKey:@"trackName"];
	}
	
    // Configure the cell
    return cell;
}

#pragma mark iTunes call and JSON parsing

- (void) getItunesSearchResults {
	NSString *termsToSearchOn = [((BoomboxViewController*) self.parentViewController).songLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSLog(@"termstosearchon: %@", termsToSearchOn);
	NSString *searchResultInJSON = [[NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/wsSearch?term=%@", termsToSearchOn]]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//NSLog(searchResultInJSON);
	NSData *jsonData = [searchResultInJSON dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	if (error) {
		NSLog(@"error with JSON conversion: %@", error);
	}
//	for (id key in dictionary) {
//		NSLog(@"key: %@, value: %@", key, [dictionary objectForKey:key]);
//	}
	self.searchResults = (NSMutableArray*) [dictionary objectForKey:@"results"];
	[theTableView reloadData];
}
@end