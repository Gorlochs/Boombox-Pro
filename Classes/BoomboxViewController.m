//
//  BoomboxViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/3/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import "BoomboxViewController.h"
#import "ControlsView.h"


@implementation BoomboxViewController

@synthesize controlsView , leftButton, rightButton;

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

- (IBAction)leftAction:(id)sender
{
	// user touched the left button in HoverView
	NSLog(@"left button clicked");
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Left Button" message:@"this is only a test" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
	searchViewController = [[iPhoneStreamingPlayerViewController alloc] initWithNibName:@"iPhoneStreamingPlayerViewController" bundle:nil];
	[self presentModalViewController:searchViewController animated:YES];
}

- (IBAction)rightAction:(id)sender
{
	// user touched the right button in HoverView
	NSLog(@"right button clicked");
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Right Button" message:@"this is only a test" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
	playlistController = [[PlaylistViewController alloc] initWithNibName:@"PlaylistView" bundle:nil];
	[self presentModalViewController:playlistController animated:YES];
}

@end
