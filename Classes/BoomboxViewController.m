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


@implementation BoomboxViewController

@synthesize controlsView, leftButton, rightButton, songLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	// determine the size of ControlsView
	CGRect frame = controlsView.frame;
	frame.origin.x = 100;
	frame.origin.y = self.view.frame.size.height - 395;
	controlsView.frame = frame;
	controlsView.backgroundColor = [UIColor clearColor];
	
	[self.view addSubview:controlsView];
	
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
	
	[leftButton release];
	[rightButton release];
	[controlsView release];
	
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

// plays a single song that was chosen on the Search page
- (IBAction)playAction:(id)sender {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BlipSong *chosenSong = appDelegate.songToPlay;
	if (chosenSong != nil) {
		if (!streamer) {
			NSString *streamUrl = [[chosenSong location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSLog(@"chosen stream: %@", streamUrl);
			NSURL *url = [NSURL URLWithString:streamUrl];
			streamer = [[AudioStreamer alloc] initWithURL:url];
			[streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
			[streamer start];
		} else {
			[streamer stop];
		}
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No song selected" message:@"Please search for, and chose, a song to play" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

#pragma mark Audio Streaming Functions

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying])
		{
			//			[self
			//				performSelector:@selector(setButtonImage:)
			//				onThread:[NSThread mainThread]
			//				withObject:[UIImage imageNamed:@"stopbutton.png"]
			//				waitUntilDone:NO];
		}
		else
		{
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
			
			//			[self
			//				performSelector:@selector(setButtonImage:)
			//				onThread:[NSThread mainThread]
			//				withObject:[UIImage imageNamed:@"playbutton.png"]
			//				waitUntilDone:NO];
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
						  context:context];
}



@end
