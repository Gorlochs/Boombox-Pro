//
//  BuySongListViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/13/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "BuySongListViewController.h"
#import "BoomboxViewController.h"
#import "CJSONDeserializer.h"
#import "BuyTableCellView.h"

@implementation BuySongListViewController

@synthesize theTableView;
@synthesize searchResults;
@synthesize searchValueForItunesStore;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil valueToSearchItunesStore:(NSString*)searchValue {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.searchValueForItunesStore = searchValue;
    }
    return self;
}

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
	[searchValueForItunesStore release];
	//[buyCell release];
	[searchResults release];
	
    [super dealloc];
}

#pragma mark TableView Delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
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
    
    BuyTableCellView *cell = (BuyTableCellView*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		UIViewController *vc = [[UIViewController alloc]initWithNibName:@"BuyTableCellView" bundle:nil];
		cell = (BuyTableCellView*) vc.view;
		[vc release];
    }
	if (self.searchResults) {
		[cell setBuyInfo:[self.searchResults objectAtIndex:indexPath.row]];
	}
	
    return cell;
}

#pragma mark UITableViewDelegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSDictionary *obj = [self.searchResults objectAtIndex:indexPath.row];
//	NSString *trackViewUrl = [obj objectForKey:@"trackViewUrl"];
//	NSString *affiliateLinkBuilder = [NSString stringWithFormat:@"http://feed.linksynergy.com/createcustomlink.shtml?token=70e56c6252f8c5cc06a3fca6586cf5f4fe767f998a9a2ac06727a0c29b1de3c8&mid=13508&murl=%@", trackViewUrl];
//	NSString *affiliateLink = [NSString stringWithContentsOfURL:[NSURL URLWithString:affiliateLinkBuilder]];
//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:affiliateLink]]; 
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *obj = [self.searchResults objectAtIndex:indexPath.row];
	NSString *trackViewUrl = [obj objectForKey:@"trackViewUrl"];
//	NSString *affiliateLinkBuilder = [NSString stringWithFormat:@"http://feed.linksynergy.com/createcustomlink.shtml?token=70e56c6252f8c5cc06a3fca6586cf5f4fe767f998a9a2ac06727a0c29b1de3c8&mid=13508&murl=%@", trackViewUrl];
//	NSLog(@"aff link builder: %@", affiliateLinkBuilder);
//	NSString *affiliateLink = [NSString stringWithContentsOfURL:[NSURL URLWithString:affiliateLinkBuilder]];
//	NSLog(@"aff link: %@", affiliateLink);
//	NSString *activateAffiliateLink = [NSString stringWithContentsOfURL:[NSURL URLWithString:affiliateLink]];
//	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]];
	NSString *revisedITunesLink = [[trackViewUrl stringByReplacingOccurrencesOfString:@"http://itunes" withString:@"http://phobos"] stringByAppendingString:@"&partnerId=30&siteID=CzRPlDJ9RUU-WcFeXe8Ar3MiH9JyMK6bZg"];
	NSLog(@"revisedITunesLink redirect? %@", revisedITunesLink);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:revisedITunesLink]];

//	NSString *affiliateLinkProxyLink = [NSString stringWithFormat:@"http://www.literalshore.com/gorloch/blip/affiliate.php?afflink=%@", [affiliateLinkBuilder stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//	NSLog(@"aff proxy link: %@", affiliateLinkProxyLink);
//	NSString *iTunesLink = [NSString stringWithContentsOfURL:[NSURL URLWithString:affiliateLinkProxyLink]];
//	NSLog(@"itunes link: %@", iTunesLink);
//	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

#pragma mark iTunes call and JSON parsing

- (void) getItunesSearchResults {
	NSString *termsToSearchOn = [self.searchValueForItunesStore stringByReplacingOccurrencesOfString:@" " withString:@"+"];
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
	if ([self.searchResults count] == 0) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"No Results Found"
							  message:@"No results found. This song might not be available on iTunes."
							  delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles: nil];
		[alert show];
		[alert release];
	} else {
		[theTableView reloadData];
	}
}
@end
