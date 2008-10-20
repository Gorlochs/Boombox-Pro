//
//  audio_testViewController.m
//  audio-test
//
//  Created by Shawn Bernard on 10/19/08.
//  Copyright Nau Inc. 2008. All rights reserved.
//

#import "audio_testViewController.h"
#import "AudioStreamer.h"


@implementation audio_testViewController

@synthesize audioButton;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (IBAction)playAudio:(id)sender {
	NSLog(@"button clicked! HURRAY!");

	NSURL *url = [NSURL URLWithString:@"http://www.captainsdead.com/myron/tomburbank/II/10%20-%20Chocolate%20Jesus%20Story.mp3"];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	[streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
	[streamer start];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualTo:@"isPlaying"]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying]) {
			NSLog(@"isPlaying == true");
//			[self
//			 performSelector:@selector(setButtonImage:)
//			 onThread:[NSThread mainThread]
//			 withObject:[NSImage imageNamed:@"stopbutton"]
//			 waitUntilDone:NO];
		} else {
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
			
//			[self
//			 performSelector:@selector(setButtonImage:)
//			 onThread:[NSThread mainThread]
//			 withObject:[NSImage imageNamed:@"playbutton"]
//			 waitUntilDone:NO];
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

@end
