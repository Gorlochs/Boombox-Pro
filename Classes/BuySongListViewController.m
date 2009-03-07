//
//  BuySongListViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/13/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "iPhoneStreamingPlayerAppDelegate.h"
#import "BuySongListViewController.h"
#import "BoomboxViewController.h"
#import "CJSONDeserializer.h"
#import "BuyTableCellView.h"
#import "Mobclix.h"

@interface BuySongListViewController (Private)
- (void)affiliateProgramUS:(NSDictionary*)obj;
- (void)affiliateProgramGB:(NSDictionary*)obj;
- (void)affiliateProgramAU:(NSDictionary*)obj;
@end


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
	
	[Mobclix logEventWithLevel: LOG_LEVEL_INFO
				   processName: @"Buy"
					 eventName: @"viewDidLoad"
				   description: @"someone is viewing the buy screen" 
				appleFramework: FW_UI_KIT
						  stop: NO
	 ]; 
	[Mobclix sync];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSString *countryCode = [appDelegate getCountryCode];	
	NSDictionary *obj = [self.searchResults objectAtIndex:indexPath.row];
	NSLog(@"buy dictionary object: %@", obj);
	
	NSArray *europeanCountries = [NSArray arrayWithObjects:@"AD",@"AL",@"AT",@"BA",@"BE",@"BG",@"BY",@"CH",@"CY",@"CZ",@"DE",@"DK",@"EE",@"ES",@"FI",@"FO",@"FR",@"GB",@"GG",@"GI",@"GR",@"HR",@"HU",@"IE",@"IM",@"IS",@"IT",@"JE",@"LI",@"LT",@"LU",@"LV",@"MC",@"MD",@"MK",@"MT",@"NL",@"NO",@"PL",@"PT",@"RO",@"RU",@"SE",@"SI",@"SJ",@"SK",@"SM",@"TR",@"UA",@"UK",@"VA",@"YU",nil];

	if ([europeanCountries containsObject:countryCode]) {
		NSLog(@"European affiliate program");
		[self affiliateProgramGB:obj];
	} else if ([countryCode isEqualToString:@"AU"]) {
		NSLog(@"Australian affiliate program");
		[self affiliateProgramAU:obj];
	} else {
		NSLog(@"US affiliate program");
		[self affiliateProgramUS:obj];
	}
}

- (void)affiliateProgramUS:(NSDictionary*)obj {
	NSString *trackViewUrl = [obj objectForKey:@"trackViewUrl"];
	NSLog(@"track to buy link: %@", trackViewUrl);
	NSString *affiliateLinkBuilder = [NSString stringWithFormat:@"http://feed.linksynergy.com/createcustomlink.shtml?token=70e56c6252f8c5cc06a3fca6586cf5f4fe767f998a9a2ac06727a0c29b1de3c8&mid=13508&murl=%@", trackViewUrl];
	NSLog(@"link builder link: %@", affiliateLinkBuilder);
	NSString *affiliateLink = [NSString stringWithContentsOfURL:[NSURL URLWithString:affiliateLinkBuilder]];
	if (affiliateLink) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]]; 
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:affiliateLink]];
	}
	NSLog(@"affiliate link: %@", affiliateLink);
	
}

- (void)affiliateProgramAU:(NSDictionary*)obj {
	NSString *baseLink = [[[obj objectForKey:@"trackViewUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingString:@"%26partnerId%3D2003"];
	NSString *affiliateLink = [@"http://www.s2d6.com/x/?x=c&z=s&v=1541356&t=" stringByAppendingString:baseLink];
	NSLog(@"Australia affiliate link: %@", affiliateLink);
	if (affiliateLink) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:affiliateLink]]; 
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:baseLink]];
	}
}

- (void)affiliateProgramGB:(NSDictionary*)obj {	
	NSString *baseLink = [[[obj objectForKey:@"trackViewUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingString:@"%26partnerId%3D2003"];
	NSString *affiliateLink = [@"http://clk.tradedoubler.com/click?p=23708&a=1607228&url=" stringByAppendingString:baseLink];
	NSLog(@"United Kingdom affiliate link: %@", affiliateLink);
	if (affiliateLink) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:affiliateLink]]; 
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:baseLink]];
	}
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
