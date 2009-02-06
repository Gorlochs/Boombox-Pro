//
//  BoomboxViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/3/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "BoomboxViewController.h"
#import "ControlsView.h"
#import "BlipSong.h"
#import <QuartzCore/CoreAnimation.h>

// Private interface - internal only methods.
@interface BoomboxViewController (Private)
- (void)stopStreamCleanup;
- (CAAnimationGroup*)imagesAnimationLeftSpeaker;
- (CAAnimationGroup*)imagesAnimationRightSpeaker;
- (void) nextPreviousCleanup;
- (void) addAnimationsToBoombox;
@end

@implementation BoomboxViewController

@synthesize controlsView, equalizerView, leftSpeakerView, rightSpeakerView, topButtonView, songLabel, audioManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	// I think that this is the wrong place for this, but initWithNibName isn't being called
	audioManager = [AudioManager sharedAudioManager];
	songLabel.font = [UIFont boldSystemFontOfSize:30];
	
	// determine the size of ControlsView
	CGRect frame = controlsView.frame;
	frame.origin.x = 110;
	frame.origin.y = self.view.frame.size.height - 241;
	controlsView.frame = frame;
	controlsView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:controlsView];
	
	// determine the size of SpeakerView
	CGRect frame2 = leftSpeakerView.frame;
	frame2.origin.x = 0;
	frame2.origin.y = self.view.frame.size.height - 410;
	leftSpeakerView.frame = frame2;
	leftSpeakerView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:leftSpeakerView];
	
	CGRect frame2a = rightSpeakerView.frame;
	frame2a.origin.x = 300;
	frame2a.origin.y = self.view.frame.size.height - 410;
	rightSpeakerView.frame = frame2a;
	rightSpeakerView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:rightSpeakerView];
	
	// determine the size of EqualizerView
	CGRect frame3 = equalizerView.frame;
	frame3.origin.x = 185;
	frame3.origin.y = self.view.frame.size.height - 358;
	equalizerView.frame = frame3;
	equalizerView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:equalizerView];
	
	// determine the size of EqualizerView
	CGRect frame4 = topButtonView.frame;
	frame4.origin.x = 10;
	frame4.origin.y = self.view.frame.size.height - 478;
	topButtonView.frame = frame4;
	topButtonView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:topButtonView];
	
	
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
	songLabel.text = [audioManager.currentSong title];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[searchViewController release];
	[playlistController release];
	[buySongListController release];
	
	[controlsView release];
	[equalizerView release];
	[leftSpeakerView release];
	[rightSpeakerView release];
	
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
	buySongListController = [[BuySongListViewController alloc] initWithNibName:@"BuySongListView" bundle:nil valueToSearchItunesStore:self.songLabel.text];
	[self presentModalViewController:buySongListController animated:YES];	
}

// plays the first song in the user's Playlist
- (IBAction)playAction:(id)sender {
	NSLog(@"play button clicked");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];  
	if ([[audioManager retrieveCurrentSongList] count] > 0) {
		NSLog(@"play button clicked, and playlist exists, so play the first song");
		[audioManager startStreamerWithPlaylistIndex:0];
		[audioManager.streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
		songLabel.text = [audioManager.currentSong constructTitleArtist];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No song selected" message:@"Please search for a song or add a song to your playlist." 
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	[pool release];
}

- (IBAction)stopStream {
	[audioManager stopStreamer];
	[self stopStreamCleanup];
}


// I know the next two methods are kinda crappy, but it was the only way I could get it all to work.
// I really wanted to put the functions in AudioManager where they belong and make these functions
// into simple delgating methods, but no luck.  There was something weird about stopping and starting
// the stream with different urls.
- (IBAction)playNextSongInPlaylist {
	if (audioManager.songIndexOfPlaylistCurrentlyPlaying > -1 && audioManager.songIndexOfPlaylistCurrentlyPlaying < [[audioManager retrieveCurrentSongList] count] - 1 && [audioManager.streamer isPlaying]) {
		// remove observer so that observeValueForKeyPath:keyPath isn't triggered by stopping the song
		[audioManager.streamer removeObserver:self forKeyPath:@"isPlaying"];
		[self stopStreamCleanup];
		// change song title immediately so that user knows what's happening
		BlipSong *nextSong = [[audioManager retrieveCurrentSongList] objectAtIndex:audioManager.songIndexOfPlaylistCurrentlyPlaying + 1];
		songLabel.text = [nextSong constructTitleArtist];	 
		
		[self addAnimationsToBoombox];
		[audioManager playNextSongInPlaylist];
		
		[audioManager.streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
	} else {
		NSLog(@"sorry, no next song in the playlist, so nothing will happen");
	}
}

- (IBAction)playPreviousSongInPlaylist {
	if (audioManager.songIndexOfPlaylistCurrentlyPlaying > 0 && audioManager.songIndexOfPlaylistCurrentlyPlaying < [[audioManager retrieveCurrentSongList] count] && [audioManager.streamer isPlaying]) {
		// remove observer so that observeValueForKeyPath:keyPath isn't triggered by stopping the song
		[audioManager.streamer removeObserver:self forKeyPath:@"isPlaying"];
		
		[self stopStreamCleanup];
		// change song title immediately so that user knows what's happening
		BlipSong *nextSong = [[audioManager retrieveCurrentSongList] objectAtIndex:audioManager.songIndexOfPlaylistCurrentlyPlaying - 1];
		songLabel.text = [nextSong constructTitleArtist];
		
		[self addAnimationsToBoombox];
		[audioManager playPreviousSongInPlaylist];
		
		[audioManager.streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
	} else {
		NSLog(@"sorry, no previous song in the playlist, so nothing will happen");
	}
}

#pragma mark Audio Streaming Functions

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context {
		
	// detects if the stream is playing a stream or not
	if ([keyPath isEqual:@"isPlaying"]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying]) {
			// a stream has started playing
			
			// start network traffic indicator in the status bar
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
			
			[self addAnimationsToBoombox];
			
			[controlsView.playButton setImage:[UIImage imageNamed:@"btn_play_on.png"] forState:UIControlStateNormal];
		} else {
			// the stream has ended 
			 
			// if user is on cell network, keep track of how many songs have been played for the day
			//[audioManager incrementCellNetworkSongsPlayed];
			
			// check to see if the finished song is in the playlist.  if so, then play next song in playlist
			if (audioManager.songIndexOfPlaylistCurrentlyPlaying > -1) {
				NSLog(@"currently playing > -1");
				if (audioManager.songIndexOfPlaylistCurrentlyPlaying < [[audioManager retrieveCurrentSongList] count] - 1) {
					NSLog(@"another song detected - getting ready to play!");
					// start streamer for next song
					[audioManager playNextSongInPlaylist];
					[audioManager.streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
					NSLog(@"playing song index %d out of %d", audioManager.songIndexOfPlaylistCurrentlyPlaying, [[audioManager retrieveCurrentSongList] count]);
					BlipSong *nextSong = [[audioManager retrieveCurrentSongList] objectAtIndex:audioManager.songIndexOfPlaylistCurrentlyPlaying];
					songLabel.text = [nextSong constructTitleArtist];					
				} else {
					NSLog(@"last song, nothing else left to play");
					// allow streamer to stop and reset index
					[audioManager stopStreamer];
					[self stopStreamCleanup];
				}
			} else {
				NSLog(@"no more songs.  cleanup");
				[self stopStreamCleanup];
			}
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void) addAnimationsToBoombox {
	// start animation
	[CATransaction begin];
	
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
	
	// adding the animation to the target layer causes it to begin animating
	[leftSpeakerView.layer addAnimation:[self imagesAnimationLeftSpeaker] forKey:@"leftSpeakerAnimation"];
	[rightSpeakerView.layer addAnimation:[self imagesAnimationRightSpeaker] forKey:@"rightSpeakerAnimation"];
	[equalizerView.layer addAnimation:[self imagesAnimation] forKey:@"equalizerAnimation"];
	
	[CATransaction commit];
}

- (void) stopStreamCleanup {
	[controlsView.playButton setImage:[UIImage imageNamed:@"btn_play_off.png"] forState:UIControlStateNormal];
	[leftSpeakerView.layer removeAnimationForKey:@"leftSpeakerAnimation"];
	[rightSpeakerView.layer removeAnimationForKey:@"rightSpeakerAnimation"];
	[equalizerView.layer removeAnimationForKey:@"equalizerAnimation"];
	songLabel.text = @"";
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

// The following two functions should be refactored
- (CAAnimationGroup*)imagesAnimationLeftSpeaker {
	
	speakerImages = [[NSMutableArray alloc] initWithCapacity:9];
	// the following array could be defined as static (so, too, probably the speakerImages above)
	NSArray *speakerValues = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:1.0],
							  [NSNumber numberWithFloat:0.99],[NSNumber numberWithFloat:0.998],
							  [NSNumber numberWithFloat:0.992],[NSNumber numberWithFloat:1.0],
							  [NSNumber numberWithFloat:0.995],[NSNumber numberWithFloat:0.999],
							  [NSNumber numberWithFloat:0.993],[NSNumber numberWithFloat:0.986],
							  [NSNumber numberWithFloat:0.996],nil];
	
	NSUInteger i, count = [speakerValues count];
	for (i = 0; i < count - 1; i++) {
		CABasicAnimation *animation;
		animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
		animation.duration=0.2;
		animation.repeatCount=1;
		animation.beginTime=0.2*i;
		animation.autoreverses=NO;
		animation.fromValue=[speakerValues objectAtIndex:i];
		animation.toValue=[speakerValues objectAtIndex:i+1];
		
		[speakerImages addObject:animation];
	}
	[speakerValues release];
	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	theGroup.animations=speakerImages;
	theGroup.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	// set the timing function for the group and the animation duration
	theGroup.duration=1.0;
	theGroup.repeatCount=1e100f;
	return theGroup;
}

- (CAAnimationGroup*)imagesAnimationRightSpeaker {
	
	speakerImages = [[NSMutableArray alloc] initWithCapacity:10];
	// the following array could be defined as static (so, too, probably the speakerImages above)
	NSArray *speakerValues = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:1.0],
							  [NSNumber numberWithFloat:0.99],
							  [NSNumber numberWithFloat:0.995],
							  [NSNumber numberWithFloat:0.986],
							  [NSNumber numberWithFloat:0.992],
							  [NSNumber numberWithFloat:1.0],
							  [NSNumber numberWithFloat:0.998],
							  [NSNumber numberWithFloat:0.993],
							  [NSNumber numberWithFloat:0.999],
							  [NSNumber numberWithFloat:0.994],
							  [NSNumber numberWithFloat:0.996],
							  nil];
	
	NSUInteger i, count = [speakerValues count];
	for (i = 0; i < count - 1; i++) {
		CABasicAnimation *animation;
		animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
		animation.duration=0.2;
		animation.repeatCount=1;
		animation.beginTime=0.2*i;
		animation.autoreverses=NO;
		animation.fromValue=[speakerValues objectAtIndex:i];
		animation.toValue=[speakerValues objectAtIndex:i+1];
		
		[speakerImages addObject:animation];
	}
	[speakerValues release];
	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	theGroup.animations=speakerImages;
	theGroup.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	// set the timing function for the group and the animation duration
	theGroup.duration=1.0;
	theGroup.repeatCount=1e100f;
	
	return theGroup;
}

@end
