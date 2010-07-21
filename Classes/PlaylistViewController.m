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
//#import "Beacon.h"
#import "iPhoneStreamingPlayerAppDelegate.h"
#import "GANTracker.h"

/*
 Setting and Getting the Delegate
 
 *   delegate  property
 
 Configuring the Advertising Shown in a Banner View
 
 *   advertisingSection  property
 *   requiredContentSizeIdentifiers  property
 
 Resizing a Banner View
 
 *   currentContentSizeIdentifier  property
 * + sizeFromBannerContentSizeIdentifier:
 
 Determining If a Banner View Is Showing an Advertisement
 
 *   bannerLoaded  property
 
 Banner Actions
 
 *   bannerViewActionInProgress  property
 * – cancelBannerViewAction
 */    

// Private interface - internal only methods.
@interface PlaylistViewController (Private)

- (void)changeImageIcons:(SearchTableCellView*)cell imageName:(NSString*)imageName;
- (void)playOrStopSong:(NSInteger)playlistIndexToPlay targetCell:(SearchTableCellView*)cell;

@end

@implementation PlaylistViewController

@synthesize theTableView, buttonView, myPlaylistButton, popularPlaylistsButton, tableCell;
@synthesize adBannerView = _adBannerView;
@synthesize bannerIsVisible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)createiAd {
	Class classAdBannerView = NSClassFromString(@"ADBannerView");
    if (classAdBannerView != nil) {
        self.adBannerView = [[[classAdBannerView alloc] initWithFrame:CGRectZero] autorelease];
        [_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: ADBannerContentSizeIdentifier480x32, nil]];
		[_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier480x32];
        [_adBannerView setFrame:CGRectOffset([_adBannerView frame], 0, 248)];
        [_adBannerView setDelegate:self];
		
        [self.view addSubview:_adBannerView];        
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	if (self.bannerIsVisible) {
		[UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
		banner.frame = CGRectOffset(banner.frame, 0, -50);
		[UIView commitAnimations];
		self.bannerIsVisible = NO;
	}
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

    [self createiAd];
	
//    NSInteger returnedValue = [self adToDisplay];
//    int rand = random() % 2;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0) returnedValue = IAD_AD_DISPLAY;
//    else returnedValue = GOOGLE_AD_DISPLAY;
//    switch (returnedValue) {
//        case 0:
//            [self createGoogleAd];
//            break;
//        case 1:
//            //[self createMobclixAd];
//            break;
//        case 2:
//            if (rand == 0) {
//                [self createGoogleAd];
//            } else {
//                //[self createMobclixAd];
//            }
//            break;
//        case 3:
//			[self createiAd];
//			break;
//        default:
//            [self createGoogleAd];
//            break;
//    }
	
    //[[Beacon shared] startSubBeaconWithName:@"Playlist" timeSession:NO];
    
	//    iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
	//    NSError *error;
	//    if (![appDelegate.ga_ trackPageview:@"/playlist" withError:&error]) {
	//        // Handle error here
	//    }
    
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
	//DLog(@"inside playlist table. playlist: %@", appDelegate.playlist);
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
    //[[Beacon shared] startSubBeaconWithName:@"Playlist Play" timeSession:NO];
}

- (void)removeModalView:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)displayMyPlaylist {
	self.navigationItem.rightBarButtonItem.enabled = YES;
	myPlaylistButton.selected = YES;
	popularPlaylistsButton.selected = NO;
	[audioManager switchToPlaylistMode:mine];
	[theTableView reloadData];
    
	//    iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
	//    NSError *error;
	//    if (![appDelegate.ga_ trackPageview:@"/playlist/my_playlist" withError:&error]) {
	//        // Handle error here
	//    }
}

- (void)displayPopularPlaylist {
	self.navigationItem.rightBarButtonItem.enabled = NO;
	popularPlaylistsButton.selected = YES;
	myPlaylistButton.selected = NO;
	[audioManager switchToPlaylistMode:popular];
	[audioManager retrieveTopSongs]; // not the best way to do this.  there should be a different way to initialize the Top Songs
	[theTableView reloadData];
    
	//    iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
	//    NSError *error;
	//    if (![appDelegate.ga_ trackPageview:@"/playlist/top_songs" withError:&error]) {
	//        // Handle error here
	//    }
}

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
	//    if (![appDelegate.ga_ trackEvent:@"playlist"
	//                  action:@"add_song_to_playlist"
	//                   label:nil
	//                   value:-1
	//               withError:&error]) {
	//        // Handle error here
	//    }
}

-(void)buySong:(id)sender {
	UIButton *senderButton = (UIButton*) sender;
	SearchTableCellView *cell = ((SearchTableCellView*) [[senderButton superview] superview]);
	BlipSong *song = [cell song];
	DLog(@"song to buy: %@", song.title);
	
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
	DLog(@"moving row from index %d to index %d", fromIndexPath.row, toIndexPath.row);
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
    //[adViewController_ release];
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
    if (audioManager.songIndexOfPlaylistCurrentlyPlaying == playlistIndexToPlay && [[audioManager streamer] isPlaying]) {
        // stop the stream and switch back to the play button
		[[NSNotificationCenter defaultCenter] postNotificationName:@"completelyStop" object:nil];
        [self changeImageIcons:cell imageName:@"image-7.png"];
    } else {
		audioManager.isSinglePlay = NO;
        [audioManager startStreamerWithPlaylistIndex:playlistIndexToPlay];		
        
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
        
		//        NSError *error;
		//        iPhoneStreamingPlayerAppDelegate *appDelegate = (iPhoneStreamingPlayerAppDelegate*)[UIApplication sharedApplication].delegate;
		//        if (![appDelegate.ga_ trackEvent:@"playlist"
		//              action:@"play_song"
		//              label:nil
		//              value:-1
		//              withError:&error]) {
		//            // Handle error here
		//        }
    }
}

@end
