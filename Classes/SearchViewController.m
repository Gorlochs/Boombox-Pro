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
#import "TouchXML.h"
//#import "Beacon.h"


#define MAX_FAIL_COUNT 3

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
@synthesize adBannerView = _adBannerView;

#pragma mark setup & tear down
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}


- (void)createiAd {
	Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adBannerView = [[[classAdBannerView alloc] 
							  initWithFrame:CGRectZero] autorelease];
        [_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: 
														  ADBannerContentSizeIdentifier480x32, nil]];
		[_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier480x32];
		
        [_adBannerView setFrame:CGRectOffset([_adBannerView frame], 0, 248)];
        [_adBannerView setDelegate:self];
		
        [self.view addSubview:_adBannerView];        
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    DLog(@"******************************************************");
    DLog(@"******************* MEMORY WARNING!!! ****************");
    DLog(@"******************************************************");
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
	[theTableView release];
	[blipSearchBar release];
	[buySongListController release];
	[topSearchViewController release];
	[searchCell release];
	
	[rssParser release];
	[item release];
	[currentTitle release];
	[currentLocation release];
	[currentArtist release];
	[currentElement release];
	
    [super dealloc];
}

- (void)viewDidLoad {
	if (audioManager.searchTerms != nil) {
		blipSearchBar.text = audioManager.searchTerms;
	}
    
	[self createiAd];
    
    if (blipSearchBar.text == nil || [blipSearchBar.text isEqualToString:@""]) {
        [blipSearchBar becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
	return NO;
}

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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	DLog(@"search button has been clicked!");
	// display activity
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	// search blip.fm api for keywords
	NSString *nonce = [AudioManager createNonce];
    
	NSString *timestamp = [NSString stringWithFormat:@"%d", abs([[NSDate date] timeIntervalSince1970])];
	DLog(@"timestamp: %@", timestamp);	

	// retrieve the hash from the php page
	NSString *tempurl = [NSString stringWithFormat:@"http://www.literalshore.com/gorloch/blip/search-1.1.1.php?nonce=%@&timestamp=%@&searchTerms=%@", nonce, timestamp, [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	//NSString *url = [[NSString stringWithContentsOfURL:[NSURL URLWithString:tempurl]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	DLog(@"final url: %@", tempurl);
	[self parseTouchXMLFileAtURL:tempurl];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self insertSearchIntoDB:searchBar.text];
	// save the search terms in the AudioManager in order to display when the screen is redisplayed
	audioManager.searchTerms = searchBar.text;
	
	[searchBar resignFirstResponder];
    //[[Beacon shared] startSubBeaconWithName:@"Search Performed" timeSession:NO];
}
- (void)insertSearchIntoDB:(NSString*)searchTerms {
	iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
	NSURL *insertUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://literalshore.com/gorloch/blip/insert-search-1.1.1.php?searchTerms=%@&cc=%@&gkey=g0rl0ch1an5",
											 [[searchTerms stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
											 [appDelegate getCountryCode]]];
	
	DLog(@"insert url: %@", insertUrl);
	NSString *insertResult = [NSString stringWithContentsOfURL:insertUrl encoding:NSUTF8StringEncoding error:nil];
	DLog(@"SVC insert result: %@", insertResult);
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
// -----------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DLog(@"number of rows returned: %d", [audioManager.songs count]);
	return [audioManager.songs count];	
}
// -----------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"loading table cell: %d", indexPath.row);
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
		DLog(@"playlist is nil");
		NSMutableArray *arr = [[NSMutableArray alloc] init];
		audioManager.playlist = arr;
		[arr release];
	}
	DLog(@"adding song....");
	[audioManager.playlist addObject:songToAdd];
	[cell.addToPlaylistButton setImage:[UIImage imageNamed:@"image-4.png"] forState:UIControlStateNormal];
	
//    NSError *error;
//    iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
//    if (![appDelegate.ga_ trackEvent:@"search"
//                  action:@"add_song_to_playlist"
//                   label:nil
//                   value:-1
//               withError:&error]) {
//        // Handle error here
//    }
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
	DLog(@"song to search on: %@", songToSearch);
	
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
	//DLog(@"finished getting the search songs xml doc: %@", theXMLDocument);
	NSArray *theNodes = NULL;
	
	theNodes = [theXMLDocument nodesForXPath:@"//BlipApiResponse/result/collection/Song" error:&theError];
	audioManager.songs = [[NSMutableArray alloc] init];
	//DLog(@"theNodes: %@", theNodes);
	
	for (CXMLElement *theElement in theNodes) {
//		DLog(@"song: %@", theElement);
//		DLog(@"song location: %@", [theElement nodesForXPath:@"./location" error:NULL]);
		NSString *loc = [[[[theElement nodesForXPath:@"./location" error:NULL] objectAtIndex:0] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([[loc substringFromIndex:[loc length] - 4] isEqualToString:@".mp3"] && [[loc substringToIndex:7] isEqualToString:@"http://"]) {
            //if ([[theElement nodesForXPath:@"./location" error:NULL] count] > 0) {
			BlipSong *tempSong = [[BlipSong alloc] init];
			tempSong.title = [[[theElement nodesForXPath:@"./title" error:NULL] objectAtIndex:0] stringValue];
			tempSong.artist = [[[theElement nodesForXPath:@"./artist" error:NULL] objectAtIndex:0] stringValue];
            tempSong.failCount = [[[[theElement nodesForXPath:@"./failCount" error:NULL] objectAtIndex:0] stringValue] intValue]; 
			tempSong.location = [[[[theElement nodesForXPath:@"./location" error:NULL] objectAtIndex:0] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			//theNodes = [theElement nodesForXPath:@"./song_name" error:NULL];
            
            DLog(@"song location: %@", tempSong.location);
            if (tempSong.failCount <= MAX_FAIL_COUNT) {
                [audioManager.songs addObject:tempSong];
            }
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
		DLog(@"TouchXML error");
	} else {
        DLog(@"table about to reload");
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
	//[cell.playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}

- (void) playOrStopSong:(SearchTableCellView*)cell songIndex:(NSInteger)songIndex {
	if ([audioManager isSongPlaying:[audioManager.songs objectAtIndex:songIndex]]) {
		// stop the stream and switch back to the play button
		if ([[audioManager streamer] isPlaying]) {
			@try {
				[audioManager.streamer removeObserver:self.parentViewController forKeyPath:@"isPlaying"];
			}
			@catch (NSException * e) {
				DLog(@"****** exception removing observer ****", e);
			}
		}
		[audioManager stopStreamer];
		[self changeImageIcons:cell imageName:@"image-7.png"];
	} else {
		BlipSong *songToPlay = [audioManager.songs objectAtIndex:songIndex];
		[audioManager startStreamerWithSong:songToPlay];
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
        //[[Beacon shared] startSubBeaconWithName:@"Search Played" timeSession:NO];
        
//        NSError *error;
//        iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
//        if (![appDelegate.ga_ trackEvent:@"search"
//                      action:@"play_song"
//                       label:nil
//                       value:-1
//                   withError:&error]) {
//            // Handle error here
//        }
	}
}

@end
