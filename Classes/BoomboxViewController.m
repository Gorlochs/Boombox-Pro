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

@synthesize controlsView , leftButton, rightButton, songLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


- (void)viewDidLoad {
	// determine the size of ControlsView
	CGRect frame = controlsView.frame;
	frame.origin.x = round((self.view.frame.size.width - frame.size.width) / 2.0);
	frame.origin.y = self.view.frame.size.height - 300;
	controlsView.frame = frame;
	controlsView.backgroundColor = [UIColor clearColor];
	
	
	[self.view addSubview:controlsView];
}

- (void)viewDidAppear {
	
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	songLabel.text = [appDelegate.songToPlay title];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[searchViewController release];
	[leftButton release];
	[rightButton release];
	[controlsView release];
	
    [super dealloc];
}

- (IBAction)displaySearchViewAction:(id)sender
{
	// user touched the left button in HoverView
	NSLog(@"left button clicked");
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Left Button" message:@"this is only a test" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
	searchViewController = [[SearchViewController alloc] initWithNibName:@"iPhoneStreamingPlayerViewController" bundle:nil];
	[self presentModalViewController:searchViewController animated:YES];
}

- (IBAction)displayPlaylistViewAction:(id)sender
{
	// user touched the right button in HoverView
	NSLog(@"right button clicked");
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Right Button" message:@"this is only a test" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
	playlistController = [[PlaylistViewController alloc] initWithNibName:@"PlaylistView" bundle:nil];
	[self presentModalViewController:playlistController animated:YES];
}

- (IBAction)playAction:(id)sender {
	if (!streamer) {
		iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		BlipSong *chosenSong = appDelegate.songToPlay;
		NSString *streamUrl = [[chosenSong location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSLog(@"chosen stream: %@", streamUrl);
		NSURL *url = [NSURL URLWithString:streamUrl];
		streamer = [[AudioStreamer alloc] initWithURL:url];
		[streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
		[streamer start];
	} else {
		[streamer stop];
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
