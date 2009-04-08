//
//  SearchViewController.m
//  SearchViewController
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "SearchViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import "iPhoneStreamingPlayerAppDelegate.h"
#import "BoomboxViewController.h"
#import "SearchTableCellView.h"
#import "Mobclix.h"
#import "TouchXML.h"
#import "AdMobView.h"

// Private interface - internal only methods.
@interface SearchViewController (Private)
- (void)changeImageIcons:(SearchTableCellView*)cell imageName:(NSString*)imageName;
- (void)playOrStopSong:(SearchTableCellView*)cell songIndex:(NSInteger)songIndex;
- (void)insertSearchIntoDB:(NSString*)searchTerms;
- (void)parseTouchXMLFileAtURL:(NSString*)URL;
@end

@implementation SearchViewController

@synthesize blipSearchBar;
@synthesize theTableView;
@synthesize searchCell;
@synthesize mobclixAdView;
@synthesize adMobAd;

// -----------------------------------------------------------------------------
#pragma mark setup & tear down
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		audioManager = [AudioManager sharedAudioManager];
	}
	return self;
}
// -----------------------------------------------------------------------------
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
// -----------------------------------------------------------------------------
- (void)dealloc {
	[theTableView release];
	[blipSearchBar release];
	[buySongListController release];
	[topSearchViewController release];
	[searchCell release];
	[mobclixAdView release];
	[adMobAd release];
    [adViewController_ release];
	
	[rssParser release];
	[item release];
	[currentTitle release];
	[currentLocation release];
	[currentArtist release];
	[currentElement release];
	
    [super dealloc];
}
// -----------------------------------------------------------------------------
- (void)viewDidLoad {
	if (audioManager.searchTerms != nil) {
		blipSearchBar.text = audioManager.searchTerms;
	}
	
	[Mobclix logEventWithLevel: LOG_LEVEL_INFO
				   processName: @"Search"
					 eventName: @"viewDidLoad"
				   description: @"someone is viewing the search screen" 
				appleFramework: FW_UI_KIT
						  stop: NO
	 ]; 
	[Mobclix sync];
    
//	adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
//	[adMobAd retain]; // this will be released when it loads (or fails to load)
    
//	mobclixAdView.adCode = @"a9a7c3c8-49c5-102c-8da0-12313a002cd2";
//	[mobclixAdView getAd];
    
    adViewController_ = [[GADAdViewController alloc] initWithDelegate:self];
    adViewController_.adSize = kGADAdSize320x50;
    
    // **************************************************************************
    // Please replace the kGADAdSenseClientID, kGADAdSenseKeywords, and
    // kGADAdSenseChannelIDs values with your own AdSense client ID, keywords,
    // and channel IDs respectively. If this application has an associated
    // iPhone Website, then set the site's URL using kGADAdSenseAppWebContentURL
    // for improved ad targeting.
    //
    // PLEASE DO NOT CLICK ON THE AD UNLESS YOU ARE IN TEST MODE. OTHERWISE, YOUR
    // ACCOUNT MAY BE DISABLED.
    // **************************************************************************
    NSNumber *channel = [NSNumber numberWithUnsignedLongLong:6305633648];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"ca-pub-6987410175123792", kGADAdSenseClientID,
                                @"free+music+mp3+download+streaming", kGADAdSenseKeywords,
                                [NSArray arrayWithObjects:channel, nil], kGADAdSenseChannelIDs,
                                [NSNumber numberWithInt:1], kGADAdSenseIsTestAdRequest,
                                nil];
    [adViewController_ loadGoogleAd:attributes];
    
    // Position ad at bottom of screen
    //CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect rect = adViewController_.view.frame;
    rect.origin = CGPointMake(80,250);
    adViewController_.view.frame = rect;
    [self.view addSubview:adViewController_.view];
}
// -----------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
	return NO;
}
// -----------------------------------------------------------------------------
char *rand_str(char *dst) {
	static const char text[] = "abcdefghijklmnopqrstuvwxyz"
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	int i;
	int len = 8;
	for ( i = 0; i < len; ++i )
	{
		dst[i] = text[rand() % (sizeof text - 1)];
	}
	dst[i] = '\0';
	return dst;
}
// -----------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"search button has been clicked!");
	// display activity
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	// search blip.fm api for keywords
	char mytext[8];
	srand(time(0));
	puts(rand_str(mytext));
	
	NSString *nonce = [NSString stringWithCString:mytext];
	NSString *timestamp = [NSString stringWithFormat:@"%d", abs([[NSDate date] timeIntervalSince1970])];
	NSLog(@"timestamp: %@", timestamp);	

	// retrieve the hash from the php page
	NSString *tempurl = [NSString stringWithFormat:@"http://www.literalshore.com/gorloch/blip/search-1.1.1.php?nonce=%@&timestamp=%@&searchTerms=%@", nonce, timestamp, [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	//NSString *url = [[NSString stringWithContentsOfURL:[NSURL URLWithString:tempurl]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSLog(@"final url: %@", tempurl);
	[self parseTouchXMLFileAtURL:tempurl];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self insertSearchIntoDB:searchBar.text];
	// save the search terms in the AudioManager in order to display when the screen is redisplayed
	audioManager.searchTerms = searchBar.text;
	
	[searchBar resignFirstResponder];
	
	[mobclixAdView getAd];
}
- (void)insertSearchIntoDB:(NSString*)searchTerms {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSURL *insertUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://literalshore.com/gorloch/blip/insert-search-1.1.1.php?searchTerms=%@&cc=%@&gkey=g0rl0ch1an5",
											 [[searchTerms stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
											 [appDelegate getCountryCode]]];
	
	NSLog(@"insert url: %@", insertUrl);
	NSString *insertResult = [NSString stringWithContentsOfURL:insertUrl];
	NSLog(@"insert result: %@", insertResult);
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
// -----------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"number of rows returned: %d", [audioManager.songs count]);
	return [audioManager.songs count];	
}
// -----------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"MyIdentifier";
	
	SearchTableCellView *cell = (SearchTableCellView *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		UIViewController *vc = [[UIViewController alloc] initWithNibName:@"SearchTableCellView" bundle:nil];
		cell = (SearchTableCellView *) vc.view;
		[vc release];
	}
	
	// Set up the cell
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	BlipSong *song = (BlipSong*) [audioManager.songs objectAtIndex: storyIndex];
	[cell setCellData:song];
	[cell.playButton addTarget:self action:@selector(playSong:) forControlEvents:UIControlEventTouchUpInside];
	[cell.addToPlaylistButton addTarget:self action:@selector(addSongToPlaylist:) forControlEvents:UIControlEventTouchUpInside];
	[cell.buyButton addTarget:self action:@selector(buySong:) forControlEvents:UIControlEventTouchUpInside];
	
	cell.playButton.tag = indexPath.row;
	cell.buyButton.tag = indexPath.row;
	cell.addToPlaylistButton.tag = indexPath.row;
//	[cell.songTitleLabel setHighlightedTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
	
	// check to see if the song is playing.  if so, then change the icon to the stop button
	if ([[[audioManager.streamer getUrl] absoluteString] isEqualToString:cell.songLocation] && [audioManager.streamer isPlaying]) {
		[cell.playButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
	} else {
		[cell.playButton setImage:[UIImage imageNamed:@"image-7.png"] forState:UIControlStateNormal];
	}
	
	// check to see if the song was added to the playlist.  if so, change image to check mark
	if ([audioManager.playlist indexOfObject:song] != NSNotFound) {
		[cell.addToPlaylistButton setImage:[UIImage imageNamed:@"image-4.png"] forState:UIControlStateNormal];
	}
	
	return cell;
}
// -----------------------------------------------------------------------------
- (void)addSongToPlaylist:(id)sender {
	UIView *senderButton = (UIView*) sender;
	SearchTableCellView *cell = ((SearchTableCellView*) [[senderButton superview] superview]);
	BlipSong *songToAdd = [cell song];
	if (audioManager.playlist == nil) {
		NSLog(@"playlist is nil");
		NSMutableArray *arr = [[NSMutableArray alloc] init];
		audioManager.playlist = arr;
		[arr release];
	}
	NSLog(@"adding song....");
	[audioManager.playlist addObject:songToAdd];
	[cell.addToPlaylistButton setImage:[UIImage imageNamed:@"image-4.png"] forState:UIControlStateNormal];
	
}
// -----------------------------------------------------------------------------
- (void)playSong:(id)sender {
	UIButton *senderButton = (UIButton*) sender;
	SearchTableCellView *cell = ((SearchTableCellView*) [[senderButton superview] superview]);
	[self playOrStopSong:cell songIndex:senderButton.tag];
}
// -----------------------------------------------------------------------------
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	SearchTableCellView *currentCell = (SearchTableCellView*) [theTableView cellForRowAtIndexPath:indexPath];
	[self playOrStopSong:currentCell songIndex:indexPath.row];
}
// -----------------------------------------------------------------------------
-(void)buySong:(id)sender {
	UIButton *senderButton = (UIButton*) sender;
	BlipSong *songToSearch = [audioManager.songs objectAtIndex:senderButton.tag];
	NSLog(@"song to search on: %@", songToSearch);
	
	buySongListController = [[BuySongListViewController alloc] initWithNibName:@"BuySongListView" 
																		bundle:nil 
													  valueToSearchItunesStore:[NSString stringWithFormat:@"%@ %@", [songToSearch.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], [songToSearch.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
	[self presentModalViewController:buySongListController animated:YES];
}
// -----------------------------------------------------------------------------
#pragma mark TouchXML parser
- (void)parseTouchXMLFileAtURL:(NSString*)URL {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSError *theError = NULL;
	CXMLDocument *theXMLDocument = [[[CXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:URL] options:0 error:&theError] autorelease];
	NSLog(@"finished getting the search songs xml doc");
	NSArray *theNodes = NULL;
	
	theNodes = [theXMLDocument nodesForXPath:@"//BlipApiResponse/result/collection/Song" error:&theError];
	audioManager.songs = [[NSMutableArray alloc] init];
	NSLog(@"theNodes: %@", theNodes);
	
	for (CXMLElement *theElement in theNodes) {
		NSLog(@"song: %@", theElement);
		NSLog(@"song location: %@", [theElement nodesForXPath:@"./location" error:NULL]);
		if ([[theElement nodesForXPath:@"./location" error:NULL] count] > 0) {
			BlipSong *tempSong = [[BlipSong alloc] init];
			tempSong.title = [[[theElement nodesForXPath:@"./title" error:NULL] objectAtIndex:0] stringValue];
			tempSong.artist = [[[theElement nodesForXPath:@"./artist" error:NULL] objectAtIndex:0] stringValue];
			tempSong.location = [[[[theElement nodesForXPath:@"./location" error:NULL] objectAtIndex:0] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			//theNodes = [theElement nodesForXPath:@"./song_name" error:NULL];
			[audioManager.songs addObject:tempSong];
			[tempSong release];
		}
	}
	[pool release];
	if (theError != NULL) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search Error" 
														message:@"Your search resulted in an error.  Please try again, or try a different search."
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		NSLog(@"TouchXML error");
	} else {
		[theTableView reloadData];
		if ([[theTableView visibleCells] count] > 0) {
			unsigned indexes[2] = {0,0};
			[theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
		}
	}
}

#pragma mark Button functions

- (IBAction)displayTopSearchesViewAction:(id)sender {
	topSearchViewController = [[TopSearchViewController alloc] initWithNibName:@"TopSearchView" bundle:nil];
	[self presentModalViewController:topSearchViewController animated:YES];
}

- (IBAction)removeModalView:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
	//[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissView:) userInfo:nil repeats:NO];
}

#pragma mark private functions
- (void) changeImageIcons:(SearchTableCellView*)cell imageName:(NSString*)imageName {
	[cell.playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	[cell.playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}

- (void) playOrStopSong:(SearchTableCellView*)cell songIndex:(NSInteger)songIndex {
	if ([audioManager isSongPlaying:[audioManager.songs objectAtIndex:songIndex]]) {
		// stop the stream and switch back to the play button
		if ([[audioManager streamer] isPlaying]) {
			@try {
				[audioManager.streamer removeObserver:self.parentViewController forKeyPath:@"isPlaying"];
			}
			@catch (NSException * e) {
				NSLog(@"****** exception removing observer ****", e);
			}
		}
		[audioManager stopStreamer];
		[self changeImageIcons:cell imageName:@"image-7.png"];
	} else {
		BlipSong *songToPlay = [audioManager.songs objectAtIndex:songIndex];
		[audioManager startStreamerWithSong:songToPlay];
		[audioManager.streamer addObserver:self.parentViewController forKeyPath:@"isPlaying" options:0 context:nil];
		((BoomboxViewController*) self.parentViewController).songLabel.text = [songToPlay constructTitleArtist];
		
		[self changeImageIcons:cell imageName:@"stop.png"];
		
		// change any other image in any other row to the default play button
		NSArray *visibleCells = [theTableView visibleCells];
		NSUInteger i, count = [visibleCells count];
		for (i = 0; i < count; i++) {
			SearchTableCellView *cell = (SearchTableCellView*) [visibleCells objectAtIndex:i];
			if (![cell.songLocation isEqualToString:[[audioManager currentSong] location]]) {
				[self changeImageIcons:cell imageName:@"image-7.png"];
			}
		}
	}
}

#pragma mark -
#pragma mark AdMobDelegate methods

- (NSString *)publisherId {
    return @"a1491a75a3b24ed"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIColor *)adBackgroundColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)adTextColor {
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (BOOL)mayAskForLocation {
    return YES; // this should be prefilled; if not, see AdMobProtocolDelegate.h for instructions
}

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob: Did receive ad");
    self.view.hidden = NO;
	CGRect frame = adMobAd.frame;
	frame.origin.x = 80;
	frame.origin.y = 252;
	adMobAd.frame = frame;
	
	adMobAd.backgroundColor = [UIColor blueColor];
    //adMobAd.frame = [self.view convertRect:self.view.frame fromView:self.view.superview]; // put the ad in the placeholder's location
    [self.view addSubview:adMobAd];
	[self.view bringSubviewToFront:adMobAd];
    autoslider = [NSTimer scheduledTimerWithTimeInterval:AD_REFRESH_PERIOD target:self selector:@selector(refreshAd:) userInfo:nil repeats:YES];
}

// Request a new ad. If a new ad is successfully loaded, it will be animated into location.
- (void)refreshAd:(NSTimer *)timer {
    [adMobAd requestFreshAd];
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
    NSLog(@"AdMob: Did fail to receive ad");
    [adMobAd release];
    adMobAd = nil;
    // we could start a new ad request here, but it is unlikely that anything has changed in the last few seconds,
    // so in the interests of the user's battery life, let's not
}

- (GADAdClickAction)adControllerActionModelForAdClick:(GADAdViewController *)adController {
    return GAD_ACTION_DISPLAY_INTERNAL_WEBSITE_VIEW;
}

- (void)adController:(GADAdViewController *)adController failedWithError:(NSError *)error {
    // Handle error here
}

@end
