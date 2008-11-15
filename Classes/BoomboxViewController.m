//
//  BoomboxViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/3/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import "BoomboxViewController.h"
#import "ControlsView.h"
#import "BlipSong.h"
#import "iPhoneStreamingPlayerAppDelegate.h"
#import <QuartzCore/CoreAnimation.h>

// Private interface for AppDelegate - internal only methods.
@interface BoomboxViewController (Private)
- (void)stopStreamCleanup;
@end

@implementation BoomboxViewController

@synthesize controlsView, speakerView, equalizerView, songLabel, streamer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	songLabel.font = [UIFont boldSystemFontOfSize:24];
//	songLabel.font = [UIFont fontWithName:@"DB LCD Temp" size:16];
//	songLabel.text = @"abcdefghijklmnopqrstuvwxyz";
//	NSArray *fonts = [UIFont familyNames];
//	NSLog(@"font families: %@", [UIFont familyNames]);
//	NSUInteger i, count = [fonts count];
//	for (i = 0; i < count; i++) {
//		NSString *fontname = [fonts objectAtIndex:i];
//		NSLog(@"font family: %@, font %@", fontname, [UIFont fontNamesForFamilyName:fontname]);
//	}
	
	
	// determine the size of ControlsView
	CGRect frame = controlsView.frame;
	frame.origin.x = 110;
	frame.origin.y = self.view.frame.size.height - 241;
	controlsView.frame = frame;
	controlsView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:controlsView];
	
	// determine the size of SpeakerView
	CGRect frame2 = speakerView.frame;
	frame2.origin.x = 0;
	frame2.origin.y = self.view.frame.size.height - 430;
	speakerView.frame = frame2;
	speakerView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:speakerView];
	
	// determine the size of EqualizerView
	CGRect frame3 = equalizerView.frame;
	frame3.origin.x = 185;
	frame3.origin.y = self.view.frame.size.height - 358;
	equalizerView.frame = frame3;
	equalizerView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:equalizerView];
	
	// the following code was obtained from Apple's iPhoneAppProgrammingGuide.pdf on pp 34-35
	UIInterfaceOrientation orientation=[[UIApplication sharedApplication] statusBarOrientation]; 
	[super viewDidLoad]; 
	if(orientation==UIInterfaceOrientationLandscapeRight){ 
		CGAffineTransform transform=self.view.transform; 
		//Use the statusbar frame to determine the center point of the window's contentarea. 
		CGRect statusBarFrame=[[UIApplication sharedApplication] 
							  statusBarFrame]; 
		
		CGRect bounds = CGRectMake(0, 0, statusBarFrame.size.height, statusBarFrame.origin.x); 
		CGPoint center = CGPointMake(bounds.size.height / 2.0, bounds.size.width / 2.0); 
		// Set the center point of the view to the center point of the window's content area. 
		self.view.center = center; 
		// Rotate the view 90 degrees around its new center point. 
		transform = CGAffineTransformRotate(transform, (M_PI / 2.0)); 
		self.view.transform = transform; 
	}
}

- (void)viewDidAppear {
	
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	songLabel.text = [appDelegate.songToPlay title];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[searchViewController release];
	[playlistController release];
	[buySongListController release];
	
	[controlsView release];
	[speakerView release];
	
	[songLabel release];
	
    [super dealloc];
}

#pragma mark Button functions

- (IBAction)displaySearchViewAction:(id)sender {
	searchViewController = [[SearchViewController alloc] initWithNibName:@"iPhoneStreamingPlayerViewController" bundle:nil];
	[self presentModalViewController:searchViewController animated:YES];
}

- (IBAction)displayPlaylistViewAction:(id)sender {
	playlistController = [[PlaylistViewController alloc] initWithNibName:@"PlaylistView" bundle:nil];
	[self presentModalViewController:playlistController animated:YES];
}

- (IBAction)displayBuyViewAction:(id)sender {
//	if ([songLabel.text isNotEqualTo:@""]) {
		buySongListController = [[BuySongListViewController alloc] initWithNibName:@"BuySongListView" bundle:nil];
		[self presentModalViewController:buySongListController animated:YES];	
//	} else {
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No song selected" message:@"A song must be selected in order to make a purchase." 
//													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//		[alert show];
//		[alert release];
//	}
}

// plays a single song that was chosen on the Search page
- (IBAction)playAction:(id)sender {
	NSLog(@"play button clicked");
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	
	if ([appDelegate.playlist count] > 0) {
		NSLog(@"play button clicked, and playlist exists, so play the first song");
		appDelegate.songIndexOfPlaylistCurrentlyPlaying = 0;
		NSString *streamUrl = [[appDelegate.playlist objectAtIndex:0] location];
		NSURL *url = [NSURL URLWithString:streamUrl];
		[streamer stop];
		streamer = [[AudioStreamer alloc] initWithURL:url];
		[streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
		[streamer start];
		songLabel.text = [[appDelegate.playlist objectAtIndex:0] constructTitleArtist];
	}
}

- (IBAction)stopStream {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	appDelegate.songIndexOfPlaylistCurrentlyPlaying = -1;
	[streamer stop];
	[self stopStreamCleanup];
//	[streamer removeObserver:@"isPlaying"];
}

#pragma mark Audio Streaming Functions

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context {
	
	// detects if the stream is playing a stream or not
	if ([keyPath isEqual:@"isPlaying"]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying]) {
			// a stream has started playing
			[CATransaction begin];
			
			[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
			[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
			
			CABasicAnimation *animation;
			animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
			animation.duration=0.1;
			animation.repeatCount=1e100f;
			animation.autoreverses=YES;
			animation.fromValue=[NSNumber numberWithFloat:1.0];
			animation.toValue=[NSNumber numberWithFloat:0.99];
			[speakerView.layer addAnimation:animation forKey:@"animateScale"];
			
			NSLog(@"eq animation about to start");
			[equalizerView.layer addAnimation:[self imagesAnimation] forKey:@"equalizerAnimation"];
			NSLog(@"eq animation started");
			
			[CATransaction commit];
			
			[controlsView.playButton setImage:[UIImage imageNamed:@"btn_play_on.png"] forState:UIControlStateNormal];
		} else {
			// the stream has ended
			
//			[streamer removeObserver:self forKeyPath:@"isPlaying"];
//			[streamer release];
//			streamer = nil;
			
			// check to see if the finished song is in the playlist.  if so, then play next song in playlist
			iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
			if (appDelegate.songIndexOfPlaylistCurrentlyPlaying > -1) {
				NSLog(@"currently playing > -1");
				if (appDelegate.songIndexOfPlaylistCurrentlyPlaying != [appDelegate.playlist count] - 1) {
					NSLog(@"another song detected - getting ready to play!");
					// start streamer for next song
					appDelegate.songIndexOfPlaylistCurrentlyPlaying++;
					BlipSong *nextSong = [appDelegate.playlist objectAtIndex:appDelegate.songIndexOfPlaylistCurrentlyPlaying];
					NSLog(@"next playlist song: %@", nextSong.title);
					[streamer stop];
					streamer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:[nextSong.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
					[streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
					[streamer start];
					songLabel.text = [nextSong constructTitleArtist];
				} else {
					NSLog(@"last song, nothing else left to play");
					// allow streamer to stop and reset index
					[streamer stop];
					appDelegate.songIndexOfPlaylistCurrentlyPlaying = -1;
					[self stopStreamCleanup];
				}
			} else {
				[self stopStreamCleanup];
			}
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void) stopStreamCleanup {
	[controlsView.playButton setImage:[UIImage imageNamed:@"btn_play_off.png"] forState:UIControlStateNormal];
	[speakerView.layer removeAnimationForKey:@"animateScale"];
	[equalizerView.layer removeAnimationForKey:@"equalizerAnimation"];
}

# pragma mark Equalizer Animation
- (CAKeyframeAnimation*)imagesAnimation;
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    [anim setDuration:5.0];
//    if( !images ) {        
        images = [[NSMutableArray alloc] initWithCapacity:32];
		
		for (int i = 1; i < 33; i++) {
			[images addObject:[[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"eq%d", i] ofType:@"png"]] CGImage]];
		}
        
        [anim setCalculationMode:kCAAnimationDiscrete];
        [anim setRepeatCount:1e100f];
		
        [anim setValues:images];
		NSLog(@"images added for animation");
//    }
    return anim;
}

@end
