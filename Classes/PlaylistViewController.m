//
//  PlaylistViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/2/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlaylistViewController.h"
#import "BlipSong.h"
#import "SearchTableCellView.h"
#import "BoomboxViewController.h"
#import "AdMobView.h"
#import "Beacon.h"

// Private interface - internal only methods.
@interface PlaylistViewController (Private)
- (void)changeImageIcons:(SearchTableCellView*)cell imageName:(NSString*)imageName;
- (void)playOrStopSong:(NSInteger)playlistIndexToPlay targetCell:(SearchTableCellView*)cell;
@end

@implementation PlaylistViewController

@synthesize theTableView, buttonView, myPlaylistButton, popularPlaylistsButton, tableCell;
@synthesize adMobAd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		NSLog(@"initializing audiomanager...");
		audioManager = [AudioManager sharedAudioManager];
		//[audioManager switchToPlaylistMode:mine];
	}
	return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[myPlaylistButton setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
	[popularPlaylistsButton setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
	if ([audioManager determinePlaylistMode] == mine) {
		myPlaylistButton.selected = YES;
	} else {
		popularPlaylistsButton.selected = YES;
	}
	
//	adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
//	[adMobAd retain]; // this will be released when it loads (or fails to load)
    
    adViewController_ = [[GADAdViewController alloc] initWithDelegate:self];
    adViewController_.adSize = kGADAdSize320x50;
    
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
    
    [[Beacon shared] startSubBeaconWithName:@"Playlist" timeSession:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([audioManager determinePlaylistMode] == mine) {
		return YES;		
	} else {
		return NO;
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
    [super setEditing:editing animated:animated];
    [theTableView setEditing:editing animated:YES];
    if (editing) {
        //addButton.enabled = NO;
    } else {
		//addButton.enabled = YES;
    }	
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[audioManager.playlist removeObjectAtIndex:indexPath.row];
        [theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];		
    }	
}

//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
//    NSString *stringToMove = [[self.reorderingRows objectAtIndex:sourceIndexPath.row] retain];
//    [self.reorderingRows removeObjectAtIndex:sourceIndexPath.row];
//    [self.reorderingRows insertObject:stringToMove atIndex:destinationIndexPath.row];
//    [stringToMove release];	
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//NSLog(@"inside playlist table. playlist: %@", appDelegate.playlist);
	if ([audioManager determinePlaylistMode] == mine) {
		return [audioManager.playlist count];		
	} else {
		return [audioManager.topSongs count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

	SearchTableCellView *cell = (SearchTableCellView *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		UIViewController *vc = [[UIViewController alloc]initWithNibName:@"SearchTableCellView" bundle:nil];
		cell = (SearchTableCellView *) vc.view;
		[vc release];
	}
	
    // Configure the cell
	int songIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	BlipSong *song = NULL;
	song = (BlipSong*) [[audioManager retrieveCurrentSongList] objectAtIndex:songIndex];
	[cell setCellData:song];
	if ([audioManager determinePlaylistMode] == mine) {
		cell.buyButton.hidden = YES;
		cell.addToPlaylistButton.hidden = YES;
	} else {
		cell.buyButton.hidden = NO;
		cell.addToPlaylistButton.hidden = NO;
		[cell.buyButton addTarget:self action:@selector(buySong:) forControlEvents:UIControlEventTouchUpInside];
		[cell.addToPlaylistButton addTarget:self action:@selector(addSongToPlaylist:) forControlEvents:UIControlEventTouchUpInside];
	}
	[cell.playButton addTarget:self action:@selector(playSong:) forControlEvents:UIControlEventTouchUpInside];
	cell.playButton.tag = indexPath.row;
	[cell.songTitleLabel setHighlightedTextColor:[UIColor colorWithWhite:0.1 alpha:1.0]];
	
	if ([audioManager isSongPlaying:song]) {
		[self changeImageIcons:cell imageName:@"stop.png"];
	} else {
		[self changeImageIcons:cell imageName:@"image-7.png"];
	}
	
	// check to see if the song was added to the playlist.  if so, change image to check mark
	if ([audioManager.playlist indexOfObject:song] != NSNotFound) {
		[cell.addToPlaylistButton setImage:[UIImage imageNamed:@"image-4.png"] forState:UIControlStateNormal];
	}
	
    return cell;
}

#pragma mark UITableViewDelegate functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SearchTableCellView *currentCell = (SearchTableCellView*) [theTableView cellForRowAtIndexPath:indexPath];
	[self playOrStopSong:indexPath.row targetCell:currentCell];
}

#pragma mark IBAction functions

- (void)playSong:(id)sender {
	UIButton *senderButton = (UIButton*) sender;
	SearchTableCellView *cell = ((SearchTableCellView*) [[senderButton superview] superview]);
	[self playOrStopSong:senderButton.tag targetCell:cell];
    [[Beacon shared] startSubBeaconWithName:@"Playlist Play" timeSession:NO];
}

- (void)removeModalView:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)displayMyPlaylist {
	myPlaylistButton.selected = YES;
	popularPlaylistsButton.selected = NO;
	[audioManager switchToPlaylistMode:mine];
	[theTableView reloadData];
}

- (void)displayPopularPlaylist {
	popularPlaylistsButton.selected = YES;
	myPlaylistButton.selected = NO;
	[audioManager switchToPlaylistMode:popular];
	[audioManager retrieveTopSongs]; // not the best way to do this.  there should be a different way to initialize the Top Songs
	[theTableView reloadData];
}

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

-(void)buySong:(id)sender {
	UIButton *senderButton = (UIButton*) sender;
	SearchTableCellView *cell = ((SearchTableCellView*) [[senderButton superview] superview]);
	BlipSong *song = [cell song];
	NSLog(@"song to buy: %@", song.title);
	
	buySongListController = [[BuySongListViewController alloc] initWithNibName:@"BuySongListView" 
																		bundle:nil 
													  valueToSearchItunesStore:[NSString stringWithFormat:@"%@ %@", [song.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], [song.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
	[self presentModalViewController:buySongListController animated:YES];
}

#pragma mark Row reordering

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
		
	return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSLog(@"moving row from index %d to index %d", fromIndexPath.row, toIndexPath.row);
	// change the order of the playlist array
	BlipSong *movedSong = [audioManager.playlist objectAtIndex:fromIndexPath.row];
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[audioManager.playlist count]];
	if (fromIndexPath.row < toIndexPath.row) {
		for (int i = 0; i < [audioManager.playlist count]; i++) {
			if (i == toIndexPath.row) {
				[tmpArray addObject:movedSong];
			} else if (i == fromIndexPath.row) {
				[tmpArray addObject:[audioManager.playlist objectAtIndex:i+1]];
			} else if (i > fromIndexPath.row && i < toIndexPath.row) {
				[tmpArray addObject:[audioManager.playlist objectAtIndex:i+1]];
			} else {
				[tmpArray addObject:[audioManager.playlist objectAtIndex:i]];
			}
		}
	} else if (fromIndexPath.row > toIndexPath.row) {
		for (int i = 0; i < [audioManager.playlist count]; i++) {
			if (i == toIndexPath.row) {
				[tmpArray addObject:movedSong];
			} else if (i == fromIndexPath.row) {
				[tmpArray addObject:[audioManager.playlist objectAtIndex:i-1]];
			} else if (i < fromIndexPath.row && i > toIndexPath.row) {
				[tmpArray addObject:[audioManager.playlist objectAtIndex:i-1]];
			} else {
				[tmpArray addObject:[audioManager.playlist objectAtIndex:i]];
			}
		}
	}
	audioManager.playlist = tmpArray;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {

	// it would be nice to compare the current size of the table to the size of the playlist
	// but I can't seem to find a programmatic way to determine how many rows are being displayed
	[theTableView reloadData];
	
    [super viewWillAppear:animated];
}

- (void)dealloc {
	[theTableView release];
    [buttonView release];
	[adMobAd release];
    
	[tableCell release];
    
    [myPlaylistButton release];
    [popularPlaylistsButton release];
    
    [buySongListController release];
	
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"isPlaying"]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
        NSArray *visibleCells = [theTableView visibleCells];
        NSUInteger i, count = [visibleCells count];
        for (i = 0; i < count; i++) {
            SearchTableCellView *cell = (SearchTableCellView*) [visibleCells objectAtIndex:i];
            if (![cell.songLocation isEqualToString:[[audioManager currentSong] location]]) {
                [self changeImageIcons:cell imageName:@"image-7.png"];
            } else {
                [self changeImageIcons:cell imageName:@"stop.png"];
            }
        }
		[pool release];
	}
}

#pragma mark private functions

- (void)changeImageIcons:(SearchTableCellView*)cell imageName:(NSString*)imageName {
	[cell.playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];	
	[cell.playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}

- (void)playOrStopSong:(NSInteger)playlistIndexToPlay targetCell:(SearchTableCellView*)cell {
    if ([[audioManager streamer] isPlaying]) {
        @try {
            [audioManager.streamer removeObserver:self.parentViewController forKeyPath:@"isPlaying"];
            [audioManager.streamer removeObserver:self forKeyPath:@"isPlaying"];
        }
        @catch (NSException * e) {
            NSLog(@"****** exception removing observer ****", e);
        }
    }
    if (audioManager.songIndexOfPlaylistCurrentlyPlaying == playlistIndexToPlay && [audioManager streamer]) {
        // stop the stream and switch back to the play button		
        [audioManager stopStreamer];
        [self changeImageIcons:cell imageName:@"image-7.png"];
    } else {
        [audioManager startStreamerWithPlaylistIndex:playlistIndexToPlay];		
        [audioManager.streamer addObserver:self.parentViewController forKeyPath:@"isPlaying" options:0 context:nil];
		[audioManager.streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
        
        // set song title label on boombox view
        ((BoomboxViewController*) self.parentViewController).songLabel.text = [[audioManager currentSong] constructTitleArtist];
        
        // change image to the stop button
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

- (GADAdClickAction)adControllerActionModelForAdClick:
(GADAdViewController *)adController {
    return GAD_ACTION_DISPLAY_INTERNAL_WEBSITE_VIEW;
}

- (void)adController:(GADAdViewController *)adController
     failedWithError:(NSError *)error {
    // Handle error here
}

@end
