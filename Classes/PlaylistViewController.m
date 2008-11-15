//
//  PlaylistViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/2/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import "PlaylistViewController.h"
#import "iPhoneStreamingPlayerAppDelegate.h"
#import "BlipSong.h"
#import "SearchTableCellView.h"
#import "AdMobView.h"


@implementation PlaylistViewController

@synthesize theTableView, tableCell, adMobAd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
	[adMobAd retain]; // this will be released when it loads (or fails to load)
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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
        //SimpleEditableListAppDelegate *controller = (SimpleEditableListAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[controller removeObjectFromListAtIndex:indexPath.row];
		iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		[appDelegate.playlist removeObjectAtIndex:indexPath.row];
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
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	//NSLog(@"inside playlist table. playlist: %@", appDelegate.playlist);
    return [appDelegate.playlist count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

	tableCell = (SearchTableCellView *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (tableCell == nil) {
		UIViewController *vc=[[UIViewController alloc]initWithNibName:@"SearchTableCellView" bundle:nil];
		tableCell = vc.view;
		[vc release];
	}
	
    // Configure the cell
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	int songIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	BlipSong *song = (BlipSong*) [appDelegate.playlist objectAtIndex: songIndex];
	[tableCell setCellData:song];
	tableCell.buyButton.hidden = YES;
	tableCell.addToPlaylistButton.hidden = YES;
	[tableCell.playButton addTarget:self action:@selector(playSong:) forControlEvents:UIControlEventTouchUpInside];
	tableCell.playButton.tag = indexPath.row;
	
	// TODO: imitate SearchViewController and make sure the stop/play buttons are correct for all rows during scrolling
	
    return tableCell;
}

- (void)playSong:(id)sender {
	UIButton *senderButton = (UIButton*) sender;
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;	
	SearchTableCellView *cell = ((SearchTableCellView*) [[senderButton superview] superview]);
	
	if (appDelegate.songIndexOfPlaylistCurrentlyPlaying == senderButton.tag) {
		// stop the stream and switch back to the play button
		[((BoomboxViewController*) self.parentViewController).streamer stop];
		[cell.playButton setImage:[UIImage imageNamed:@"image-7.png"] forState:UIControlStateNormal];
		appDelegate.songIndexOfPlaylistCurrentlyPlaying = -1;
	} else {
		BlipSong *songToPlay = [appDelegate.playlist objectAtIndex:senderButton.tag];
		NSString *streamUrl = [songToPlay.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSLog(@"chosen stream: %@", streamUrl);
		NSURL *url = [NSURL URLWithString:streamUrl];
		
		if (((BoomboxViewController*) self.parentViewController).streamer) {
			[((BoomboxViewController*) self.parentViewController).streamer removeObserver:self.parentViewController forKeyPath:@"isPlaying"];
			[((BoomboxViewController*) self.parentViewController).streamer stop];
//			[((BoomboxViewController*) self.parentViewController).streamer release];
//			((BoomboxViewController*) self.parentViewController).streamer = nil;
		}
		((BoomboxViewController*) self.parentViewController).streamer = [[AudioStreamer alloc] initWithURL:url];
		[((BoomboxViewController*) self.parentViewController).streamer addObserver:self.parentViewController forKeyPath:@"isPlaying" options:0 context:nil];
		[((BoomboxViewController*) self.parentViewController).streamer start];	
		
		// set the delegate's variables so that it knows that the playlist is playing.
		appDelegate.songIndexOfPlaylistCurrentlyPlaying = senderButton.tag;
		
		// set song title label on boombox view
		((BoomboxViewController*) self.parentViewController).songLabel.text = [songToPlay constructTitleArtist];
		
		// change image to the stop button
		[cell.playButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
		
		// change any other image in any other row to the default play button
		NSArray *visibleCells = [theTableView visibleCells];
		NSUInteger i, count = [visibleCells count];
		for (i = 0; i < count; i++) {
			SearchTableCellView *cell = (SearchTableCellView*) [visibleCells objectAtIndex:i];
			if (![cell.songLocation isEqualToString:streamUrl]) {
				[cell.playButton setImage:[UIImage imageNamed:@"image-7.png"] forState:UIControlStateNormal];
			}
		}
	}
}

#pragma mark Row reordering

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
		
	return proposedDestinationIndexPath;
}

// TODO: fix this
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSLog(@"moving row from index %d to index %d", fromIndexPath.row, toIndexPath.row);
	// change the order of the playlist array
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BlipSong *movedSong = [appDelegate.playlist objectAtIndex:fromIndexPath.row];
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[appDelegate.playlist count]];
	for (int i = 0; i < [appDelegate.playlist count]; i++) {
		NSLog(@"i = %d", i);
		if (i == toIndexPath.row) {
			NSLog(@"i == toIndexPath.row");
			[tmpArray addObject:movedSong];
		} else if (i == fromIndexPath.row) {
			NSLog(@"i == fromIndexPath.row");
			[tmpArray addObject:[appDelegate.playlist objectAtIndex:i+1]];
		} else if (i > fromIndexPath.row && i < toIndexPath.row) {
			[tmpArray addObject:[appDelegate.playlist objectAtIndex:i+1]];
		} else {
			NSLog(@"else");
			[tmpArray addObject:[appDelegate.playlist objectAtIndex:i]];
		}
	}
	appDelegate.playlist = tmpArray;
//	NSUInteger rangeLength = toIndexPath.row - fromIndexPath.row;
//	[appDelegate.playlist replaceObjectsInRange:NSMakeRange(fromIndexPath.row + 1, rangeLength) withObjectsFromArray:appDelegate.playlist range:NSMakeRange(fromIndexPath.row, rangeLength)];
//	[appDelegate.playlist insertObject:movedSong atIndex:toIndexPath.row];
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

- (IBAction)removeModalView:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[theTableView release];
	[adMobAd release];
	
    [super dealloc];
}

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

@end

