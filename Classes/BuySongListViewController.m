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
	
	NSArray *europeanCountries;
	[europeanCountries initWithObjects:@"AD",@"AL",@"AT",@"BA",@"BE",@"BG",@"BY",@"CH",@"CY",@"CZ",@"DE",@"DK",@"EE",@"ES",@"FI",@"FO",@"FR",@"GB",@"GG",@"GI",@"GR",@"HR",@"HU",@"IE",@"IM",@"IS",@"IT",@"JE",@"LI",@"LT",@"LU",@"LV",@"MC",@"MD",@"MK",@"MT",@"NL",@"NO",@"PL",@"PT",@"RO",@"RU",@"SE",@"SI",@"SJ",@"SK",@"SM",@"TR",@"UA",@"UK",@"VA",@"YU",nil];

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
	NSString *affiliateLink = [NSString stringWithContentsOfURL:[NSURL URLWithString:affiliateLinkBuilder]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:affiliateLink]]; 
}

- (void)affiliateProgramAU:(NSDictionary*)obj {
	NSString *baseLink = [[[obj objectForKey:@"trackViewUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingString:@"%26partnerId%3D2003"];
	NSString *affiliateLink = [@"http://www.s2d6.com/x/?x=c&z=s&v=1541356&t=" stringByAppendingString:baseLink];
	NSLog(@"Australia affiliate link: %@", affiliateLink);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:affiliateLink]]; 
}

- (void)affiliateProgramGB:(NSDictionary*)obj {
//	NSLog(@"artistName: %@", [[obj objectForKey:@"artistName"] stringByReplacingOccurrencesOfString:@" " withString:@"%2B"]);
//	NSLog(@"collectionName: %@", [[obj objectForKey:@"collectionName"] stringByReplacingOccurrencesOfString:@" " withString:@"%2B"]);
//	NSLog(@"trackName: %@", [[obj objectForKey:@"trackName"] stringByReplacingOccurrencesOfString:@" " withString:@"%2B"]);
//	
//	NSString *artistName = [[obj objectForKey:@"artistName"] stringByReplacingOccurrencesOfString:@" " withString:@"%2B"];
//	NSString *collectionName = [[obj objectForKey:@"collectionName"] stringByReplacingOccurrencesOfString:@" " withString:@"%2B"];
//	NSString *trackName = [[obj objectForKey:@"trackName"] stringByReplacingOccurrencesOfString:@" " withString:@"%2B"];
//	NSString *affiliateLink = [NSString stringWithFormat:@"http://clk.tradedoubler.com/click?p=23708&a=%@&url=http3A2F2Fphobos.apple.com2FWebObjects%2FMZSearch.woa2Fwa2FadvancedSearchResults3FartistTerm3D%@26albumTerm3D%@26songTerm3D%@%26s3D14344426partnerId3D2003",
//							   @"1607228",
//							   artistName,
//							   collectionName,
//							   trackName];;
	
	NSString *baseLink = [[[obj objectForKey:@"trackViewUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingString:@"%26partnerId%3D2003"];
// 	NSString *affiliateLink = [[[[[[@"http://clk.tradedoubler.com/click?p=23708&a=1607228&url=http%3A%2F%2Fphobos.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FadvancedSearchResults%3FartistTerm%3D" stringByAppendingString:artistName] stringByAppendingString:@"%26albumTerm%3D"] stringByAppendingString:collectionName] stringByAppendingString:@"%26songTerm%3D"] stringByAppendingString:trackName] stringByAppendingString:@"%26s%3D143444%26partnerId%3D2003"];
	NSString *affiliateLink = [@"http://clk.tradedoubler.com/click?p=23708&a=1607228&url=" stringByAppendingString:baseLink];
	NSLog(@"United Kingdom affiliate link: %@", affiliateLink);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:affiliateLink]]; 
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSDictionary *obj = [self.searchResults objectAtIndex:indexPath.row];
//	NSString *trackViewUrl = [obj objectForKey:@"trackViewUrl"];
//	NSString *affiliateLinkBuilder = [NSString stringWithFormat:@"http://feed.linksynergy.com/createcustomlink.shtml?token=70e56c6252f8c5cc06a3fca6586cf5f4fe767f998a9a2ac06727a0c29b1de3c8&mid=13508&murl=%@", trackViewUrl];
//	NSLog(@"aff link builder: %@", affiliateLinkBuilder);
////	NSString *affiliateLink = [NSString stringWithContentsOfURL:[NSURL URLWithString:affiliateLinkBuilder]];
////	NSLog(@"aff link: %@", affiliateLink);
////	NSString *activateAffiliateLink = [NSString stringWithContentsOfURL:[NSURL URLWithString:affiliateLink]];
////	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]];
////	NSString *revisedITunesLink = [[trackViewUrl stringByReplacingOccurrencesOfString:@"http://itunes" withString:@"http://phobos"] stringByAppendingString:@"&partnerId=30&siteID=CzRPlDJ9RUU-WcFeXe8Ar3MiH9JyMK6bZg"];
////	NSLog(@"revisedITunesLink redirect? %@", revisedITunesLink);
////	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:revisedITunesLink]];
//
//	NSString *affiliateLinkProxyLink = [NSString stringWithFormat:@"http://www.literalshore.com/gorloch/blip/affiliate.php?afflink=%@", [affiliateLinkBuilder stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//	NSLog(@"aff proxy link: %@", affiliateLinkProxyLink);
////	NSString *iTunesLink = [NSString stringWithContentsOfURL:[NSURL URLWithString:affiliateLinkProxyLink]];
////	NSLog(@"itunes link: %@", iTunesLink);
////	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
//
//}

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
