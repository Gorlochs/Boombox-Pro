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
#import "AdMobView.h"

#define API_KEY @"b6075b6c7ec95c4c5ecf"

// Private interface - internal only methods.
@interface SearchViewController (Private)
- (void)changeImageIcons:(SearchTableCellView*)cell imageName:(NSString*)imageName;
@end

@implementation SearchViewController

@synthesize blipSearchBar;
@synthesize theTableView;
@synthesize searchCell;
@synthesize adMobAd;

// -----------------------------------------------------------------------------
#pragma mark setup & tear down
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
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
	[adMobAd release];
	[buySongListController release];
	[searchCell release];
	
	
	[rssParser release];
	//[songs release];
	[item release];
	[currentTitle release];
	[currentLocation release];
	[currentArtist release];
	[currentElement release];
	
    [super dealloc];
}
// -----------------------------------------------------------------------------
- (void)viewDidLoad {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	if (appDelegate.searchTerms != nil) {
		blipSearchBar.text = appDelegate.searchTerms;
	}
	adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
	[adMobAd retain]; // this will be released when it loads (or fails to load)
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
	// dismiss keyboard
	
	// search blip.fm api for keywords
	char mytext[8];
	srand(time(0));
	puts(rand_str(mytext));
	
	NSString *nonce = [NSString stringWithCString:mytext];
	NSString *timestamp = [NSString stringWithFormat:@"%d", abs([[NSDate date] timeIntervalSince1970])];
	NSLog(@"timestamp: %@", timestamp);	

	// retrieve the hash from the php page
	NSString *tempurl = [NSString stringWithFormat:@"http://www.literalshore.com/gorloch/blip/encrypt.php?nonce=%@&timestamp=%@", nonce, timestamp];
	NSString *url = [[NSString stringWithFormat:@"http://api.blip.fm/search/findSongs.xml?apiKey=%@&searchTerm=%@&nonce=%@&timestamp=%@&signature=%@", 
					  API_KEY, 
					  [searchBar.text  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
					  nonce,
					  timestamp,
					  [NSString stringWithContentsOfURL:[NSURL URLWithString:tempurl]]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSLog(@"parse url: %@", url);
	[self parseXMLFileAtURL:url];
	
	// save the search terms in the appdelegate in order to display when the screen is redisplayed
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	appDelegate.searchTerms = searchBar.text;
	
	[searchBar resignFirstResponder];
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
// -----------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	return [appDelegate.songs count];	
}
// -----------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"MyIdentifier";
	
	searchCell = (SearchTableCellView *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (searchCell == nil) {
//		[[NSBundle mainBundle] loadNibNamed:@"SearchTableCellView" owner:self options:nil];
//		NSArray *cellNib = [[NSBundle mainBundle] loadNibNamed:@"SearchTableCellView" owner:self options:nil];
//		cell = (SearchTableCellView *)[cellNib objectAtIndex:1];
		
		UIViewController *vc=[[UIViewController alloc] initWithNibName:@"SearchTableCellView" bundle:nil];
		searchCell = vc.view;
		[vc release];
	}
	
	// Set up the cell
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BlipSong *song = (BlipSong*) [appDelegate.songs objectAtIndex: storyIndex];
	[searchCell setCellData:song];
	[searchCell.playButton addTarget:self action:@selector(playSong:) forControlEvents:UIControlEventTouchUpInside];
	[searchCell.addToPlaylistButton addTarget:self action:@selector(addSongToPlaylist:) forControlEvents:UIControlEventTouchUpInside];
	[searchCell.buyButton addTarget:self action:@selector(buySong:) forControlEvents:UIControlEventTouchUpInside];
	
	searchCell.playButton.tag = indexPath.row;
	searchCell.buyButton.tag = indexPath.row;
	searchCell.addToPlaylistButton.tag = indexPath.row;
	[searchCell.songTitleLabel setHighlightedTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
	
	// check to see if the song is playing.  if so, then change the icon to the stop button
	if ([[[((BoomboxViewController*) self.parentViewController).streamer getUrl] absoluteString] isEqualToString:searchCell.songLocation]) {
		[searchCell.playButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
	} else {
		[searchCell.playButton setImage:[UIImage imageNamed:@"image-7.png"] forState:UIControlStateNormal];
	}
	
	// check to see if the song was added to the playlist.  if so, change image to check mark
	if ([appDelegate.playlist indexOfObject:song] != NSNotFound) {
		[searchCell.addToPlaylistButton setImage:[UIImage imageNamed:@"image-4.png"] forState:UIControlStateNormal];
	}
	
	return searchCell;
}
// -----------------------------------------------------------------------------
- (void)addSongToPlaylist:(id)sender {
	UIView *senderButton = (UIView*) sender;
	SearchTableCellView *cell = ((SearchTableCellView*) [[senderButton superview] superview]);
	BlipSong *songToAdd = [cell song];
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	//BlipSong *song = (BlipSong*) [appDelegate.songs objectAtIndex: indexPath.row];
	if (appDelegate.playlist == nil) {
		NSLog(@"playlist is nil");
		appDelegate.playlist = [[NSMutableArray alloc] init];
	}
	NSLog(@"adding song....");
	[appDelegate.playlist addObject:songToAdd];
	[cell.addToPlaylistButton setImage:[UIImage imageNamed:@"image-4.png"] forState:UIControlStateNormal];
	
}
// -----------------------------------------------------------------------------
- (void)playSong:(id)sender {
	UIButton *senderButton = (UIButton*) sender;
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;	
	SearchTableCellView *cell = ((SearchTableCellView*) [[senderButton superview] superview]);
	
	if ([[[appDelegate.songs objectAtIndex:senderButton.tag] location] isEqualToString:[[((BoomboxViewController*) self.parentViewController).streamer getUrl] absoluteString]]) {
		// stop the stream and switch back to the play button
		[((BoomboxViewController*) self.parentViewController).streamer stop];
		appDelegate.songIndexOfPlaylistCurrentlyPlaying = -1;
		[self changeImageIcons:cell imageName:@"image-7.png"];
	} else {
		BlipSong *songToPlay = [appDelegate.songs objectAtIndex:senderButton.tag];
		appDelegate.songIndexOfPlaylistCurrentlyPlaying = -1;  // set it to -1 so the player knows the playlist isn't currently playing
		
		NSString *streamUrl = [cell.songLocation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSLog(@"chosen stream: %@", streamUrl);
		NSURL *url = [NSURL URLWithString:streamUrl];
		
		if (((BoomboxViewController*) self.parentViewController).streamer) {
			[((BoomboxViewController*) self.parentViewController).streamer stop];
		}
		((BoomboxViewController*) self.parentViewController).streamer = [[AudioStreamer alloc] initWithURL:url];
		[((BoomboxViewController*) self.parentViewController).streamer addObserver:self.parentViewController forKeyPath:@"isPlaying" options:0 context:nil];
		[((BoomboxViewController*) self.parentViewController).streamer start];
		((BoomboxViewController*) self.parentViewController).songLabel.text = [songToPlay constructTitleArtist];
		
		[self changeImageIcons:cell imageName:@"stop.png"];
		
		// change any other image in any other row to the default play button
		NSArray *visibleCells = [theTableView visibleCells];
		NSUInteger i, count = [visibleCells count];
		for (i = 0; i < count; i++) {
			SearchTableCellView *cell = (SearchTableCellView*) [visibleCells objectAtIndex:i];
			if (![cell.songLocation isEqualToString:streamUrl]) {
				[self changeImageIcons:cell imageName:@"image-7.png"];
			}
		}
	}
}
-(void)buySong:(id)sender {
	UIButton *senderButton = (UIButton*) sender;
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;	
	BlipSong *songToSearch = [appDelegate.songs objectAtIndex:senderButton.tag];
	NSLog(@"song to search on: %@", songToSearch);
	
	buySongListController = [[BuySongListViewController alloc] initWithNibName:@"BuySongListView" 
																		bundle:nil 
													  valueToSearchItunesStore:[NSString stringWithFormat:@"%@ %@", [songToSearch.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], [songToSearch.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
	[self presentModalViewController:buySongListController animated:YES];
}
// -----------------------------------------------------------------------------
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	SearchTableCellView *currentCell = (SearchTableCellView*) [theTableView cellForRowAtIndexPath:indexPath];
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;	
	
	if ([[[appDelegate.songs objectAtIndex:indexPath.row] location] isEqualToString:[[((BoomboxViewController*) self.parentViewController).streamer getUrl] absoluteString]]) {
		// stop the stream and switch back to the play button
		appDelegate.songIndexOfPlaylistCurrentlyPlaying = -1;
		[((BoomboxViewController*) self.parentViewController).streamer stop];
		[self changeImageIcons:currentCell imageName:@"image-7.png"];
	} else {
		BlipSong *songToPlay = [appDelegate.songs objectAtIndex:indexPath.row];
		NSString *streamUrl = [songToPlay.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSLog(@"chosen stream: %@", streamUrl);
		NSURL *url = [NSURL URLWithString:streamUrl];
		
		// stop stream if some other stream is already playing
		if (((BoomboxViewController*) self.parentViewController).streamer) {
			[((BoomboxViewController*) self.parentViewController).streamer removeObserver:self.parentViewController forKeyPath:@"isPlaying"];
			[((BoomboxViewController*) self.parentViewController).streamer stop];
		}
		((BoomboxViewController*) self.parentViewController).streamer = [[AudioStreamer alloc] initWithURL:url];
		[((BoomboxViewController*) self.parentViewController).streamer addObserver:self.parentViewController forKeyPath:@"isPlaying" options:0 context:nil];
		[((BoomboxViewController*) self.parentViewController).streamer start];	
		
		// set the delegate's variables so that it knows that the playlist is not playing.
		appDelegate.songIndexOfPlaylistCurrentlyPlaying = -1;
		
		// set song title label on boombox view
		((BoomboxViewController*) self.parentViewController).songLabel.text = [songToPlay constructTitleArtist];
		
		// change image to the stop button
		[self changeImageIcons:currentCell imageName:@"stop.png"];
		
		// change any other image in any other row to the default play button
		NSArray *visibleCells = [theTableView visibleCells];
		NSUInteger i, count = [visibleCells count];
		for (i = 0; i < count; i++) {
			SearchTableCellView *cell = (SearchTableCellView*) [visibleCells objectAtIndex:i];
			if (![cell.songLocation isEqualToString:streamUrl]) {
				[self changeImageIcons:cell imageName:@"image-7.png"];
			}
		}
	}
}

// -----------------------------------------------------------------------------
#pragma mark Parser 
- (void)parserDidStartDocument:(NSXMLParser *)parser{	
	//	NSLog(@"found file and started parsing");
}
// -----------------------------------------------------------------------------
- (void)parseXMLFileAtURL:(NSString *)URL {
	// always start with a fresh, empty array
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	appDelegate.songs = [[NSMutableArray alloc] init];
	
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
	NSString *returnstring = [NSString stringWithContentsOfURL:xmlURL];
	NSLog(@"api return xml: %@", returnstring);

    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
	NSLog(@"***** before parser init *****");
    //rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	NSLog(@"***** after parser init *****");
	rssParser = [[NSXMLParser alloc] initWithData:[returnstring dataUsingEncoding:NSASCIIStringEncoding]];
	
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
	
    [rssParser parse];
	
}
// -----------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[errorAlert show];
}
// -----------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    //NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"Song"]) {
		// clear out our story item caches...
		item = [[BlipSong alloc] init];
		
		currentTitle = [[NSMutableString alloc] init];
		currentArtist = [[NSMutableString alloc] init];
		currentLocation = [[NSMutableString alloc] init];
	}
}
// -----------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"Song"]) {
		// save values to an item, then store that item into the array...
		[item setTitle:currentTitle];
		[item setArtist:currentArtist];
		[item setLocation:[currentLocation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		
		[currentTitle release];
		[currentLocation release];
		[currentArtist release];
		
		iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		//if ([item.location isNotEqualTo:@""]) {
		if (![item.location isEqualToString:@""]){
			[appDelegate.songs addObject:item];
		}
		NSLog(@"adding song: %@", currentTitle);
		//		NSLog(@"1adding summary: %@", currentSummary);
	}
}
// -----------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"artist"]) {
		[currentArtist appendString:string];
	} else if ([currentElement isEqualToString:@"location"]) {
		[currentLocation appendString:string];
	} else if ([currentElement isEqualToString:@"message"]) {
		NSLog(@"******* error message: %@", string);
	}
}
// -----------------------------------------------------------------------------
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	//	NSLog(@"songs array has %d items", [songs count]);
	
	[theTableView reloadData];
	[theTableView setHidden:NO];
	
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	if ([appDelegate.songs count] == 0) {
		UIAlertView *alert = [[UIAlertView alloc]
								initWithTitle:@"No Results Found"
								message:@"No results found. Please check your spelling or try another search."
								delegate:self
								cancelButtonTitle:@"OK"
								otherButtonTitles: nil];
		[alert show];
		[alert release];
	} else {
		unsigned indexes[2] = {0,0};
		[theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
	//	[bigSpinner stopAnimating];
}

- (IBAction)removeModalView:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
	//[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissView:) userInfo:nil repeats:NO];
}

//- (void) dismissView:(id)sender {
//	[self dismissModalViewControllerAnimated:YES];
//}

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
	return NO; // this should be prefilled; if not, see AdMobProtocolDelegate.h for instructions
}

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
	NSLog(@"AdMob: Did receive ad");
	self.view.hidden = NO;
	//adMobAd.frame = CGRectMake(0, 350, 320, 48); 
	
	CGRect frame = adMobAd.frame;
	frame.origin.x = 80;
	frame.origin.y = 252;
	adMobAd.frame = frame;
	
	adMobAd.backgroundColor = [UIColor blueColor];
	adMobAd.hidden = NO;
	//adMobAd.frame = [self.view convertRect:self.view.frame fromView:self.view.superview]; // put the ad in the placeholder's location
	[self.view addSubview:adMobAd];
	[self.view bringSubviewToFront:adMobAd];
	NSLog(@"subview added");
	autoslider = [NSTimer scheduledTimerWithTimeInterval:AD_REFRESH_PERIOD target:self selector:@selector(refreshAd:) userInfo:nil repeats:YES];
}

// Request a new ad. If a new ad is successfully loaded, it will be animated into location.
- (void)refreshAd:(NSTimer *)timer {
	NSLog(@"ad is refreshing...");
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

#pragma mark private functions
- (void)changeImageIcons:(SearchTableCellView*)cell imageName:(NSString*)imageName {
	[cell.playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	[cell.playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}

@end
