//
//  iPhoneStreamingPlayerViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "iPhoneStreamingPlayerViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import "iPhoneStreamingPlayerAppDelegate.h"

#define API_KEY @"b6075b6c7ec95c4c5ecf"

@implementation iPhoneStreamingPlayerViewController

@synthesize blipPlaylist;
@synthesize blipSearchBar;
@synthesize theTableView;

// -----------------------------------------------------------------------------
#pragma mark setup & tear down
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}
// -----------------------------------------------------------------------------
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}
// -----------------------------------------------------------------------------
- (void)dealloc {
	[theTableView release];
	[blipSearchBar release];
	
	[rssParser release];
	[songs release];
	[item release];
	[currentTitle release];
	[currentLocation release];
	[currentArtist release];
	
	[blipPlaylist release];
	
    [super dealloc];
}

//- (void)setButtonImage:(UIImage *)image
//{
//	[button.layer removeAllAnimations];
//	[button
//		setImage:image
//		forState:0];
//}

- (void)viewDidLoad
{
//	UIImage *image = [UIImage imageNamed:@"playbutton.png"];
//	[self setButtonImage:image];
	[blipPlaylist initWithCapacity:50];
}

//- (void)spinButton
//{
//	[CATransaction begin];
//	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//	CGRect frame = [button frame];
//	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
//	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
//	[CATransaction commit];
//
//	[CATransaction begin];
//	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
//	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
//
//	CABasicAnimation *animation;
//	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//	animation.fromValue = [NSNumber numberWithFloat:0.0];
//	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
//	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
//	animation.delegate = self;
//	[button.layer addAnimation:animation forKey:@"rotationAnimation"];
//
//	[CATransaction commit];
//}
//
//- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
//{
//	if (finished)
//	{
//		[self spinButton];
//	}
//}
//
//- (IBAction)buttonPressed:(id)sender
//{
//	if (!streamer)
//	{
//		[textField resignFirstResponder];
//		
//		NSURL *url = [NSURL URLWithString:[textField text]];
//		streamer = [[AudioStreamer alloc] initWithURL:url];
//		[streamer
//			addObserver:self
//			forKeyPath:@"isPlaying"
//			options:0
//			context:nil];
//		[streamer start];
//
//		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
//
//		[self spinButton];
//	}
//	else
//	{
//		[button.layer removeAllAnimations];
//		[streamer stop];
//	}
//}

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

- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
//	[self buttonPressed:sender];
	return NO;
}

char *rand_str(char *dst)
{
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
	NSLog(@"search button has been clicked!");
	// dismiss keyboard
	
	// search blip.fm api for keywords
	char mytext[8];
	srand(time(0));
	puts(rand_str(mytext));
	
	NSString *nonce = [NSString stringWithCString:mytext];
	NSString *timestamp = [NSString stringWithFormat:@"%d", abs([[NSDate date] timeIntervalSince1970])];
	NSLog(@"timestamp: %@", timestamp);	

	// retrieve the hash from the php page
	NSString *tempurl = [NSString stringWithFormat:@"http://www.literalshore.com/gorloch/blip/encrypt.php?nonce=%@&timestamp=%@", nonce, timestamp];
	NSLog(@"string from url: %@", [NSString stringWithContentsOfURL:[NSURL URLWithString:tempurl]]);
	
	NSString *url = [[NSString stringWithFormat:@"http://api.blip.fm/search/findSongs.xml?apiKey=%@&searchTerm=%@&nonce=%@&timestamp=%@&signature=%@", 
					  API_KEY, 
					  [searchBar.text  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
					  nonce,
					  timestamp,
					  [NSString stringWithContentsOfURL:[NSURL URLWithString:tempurl]]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSLog(@"parse url: %@", url);
	[self parseXMLFileAtURL:url];
	
	[searchBar resignFirstResponder];
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
// -----------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [songs count];	
}
// -----------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	cell.font = [UIFont systemFontOfSize:14.0];
	
	// Set up the cell
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	BlipSong *song = (BlipSong*) [songs objectAtIndex: storyIndex];
//	cell.target = self;
	//cell.frame = CGRectMake(0, 0, 180, 80);
	cell.text = song.title;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//	cell.accessoryAction = @selector(onClick:);
	//	cell.story = story;
	//	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

	BlipSong *song = (BlipSong*) [songs objectAtIndex: indexPath.row];
	NSLog(@"song to add: %@", song.title);
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	if (appDelegate.playlist == nil) {
		NSLog(@"playlist is nil");
		appDelegate.playlist = [[NSMutableArray alloc] init];
	}
	NSLog(@"adding song....");
	[appDelegate.playlist addObject:song];
	NSLog(@"playlist: %@", appDelegate.playlist);
}
// -----------------------------------------------------------------------------
// called when the accessory view (disclosure button) is touched
//- (void)onClick:(id)sender
//{
//	NSLog(@"******   onclick; sender: %@", sender);
////	NSLog(@"******   onclick; song: %@", song);
////	NSLog(@"******   onclick; foo: %@", foo);
//	//BlipSong *song = (BlipSong*) sender;
//	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//	if (appDelegate.playlist == nil) {
//		NSLog(@"playlist is nil");
//		appDelegate.playlist = [NSArray array];
//	}
////	[appDelegate.playlist arrayByAddingObject:song];
//	NSLog(@"playlist: ", appDelegate.playlist);
//
////	NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
////							  self.title, @"text",
////							  [NSNumber numberWithBool:self.checked], @"checked",
////							  nil];
////	[appDelegate showDetail:infoDict];
//}
// -----------------------------------------------------------------------------
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (!streamer) {
		BlipSong *chosenSong = [songs objectAtIndex:indexPath.row];
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

// -----------------------------------------------------------------------------
#pragma mark Parser 
- (void)parserDidStartDocument:(NSXMLParser *)parser{	
	//	NSLog(@"found file and started parsing");
}
// -----------------------------------------------------------------------------
- (void)parseXMLFileAtURL:(NSString *)URL
{
	// always start with a fresh, empty array
	songs = [[NSMutableArray alloc] init];
	
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
	
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [rssParser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
	
    [rssParser parse];
	
}
// -----------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[errorAlert show];
}
// -----------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    //NSLog(@"found this element: %@", elementName);
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"Song"]) {
		// clear out our story item caches...
		item = [[BlipSong alloc] init];
		
		currentTitle = [[NSMutableString alloc] init];
		currentArtist = [[NSMutableString alloc] init];
		currentLocation = [[NSMutableString alloc] init];
	}
}
// -----------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	//NSLog(@"ended element: %@", elementName);
	if ([elementName isEqualToString:@"Song"]) {
		// save values to an item, then store that item into the array...
		[item setTitle:currentTitle];
		[item setArtist:currentArtist];
		[item setLocation:currentLocation];
		
		[currentTitle release];
		[currentLocation release];
		[currentArtist release];
		
		[songs addObject:item];
		NSLog(@"adding song: %@", currentTitle);
		//		NSLog(@"1adding summary: %@", currentSummary);
	}
}
// -----------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"artist"]) {
		[currentArtist appendString:string];
	} else if ([currentElement isEqualToString:@"location"]) {
		[currentLocation appendString:string];
	} else if ([currentElement isEqualToString:@"message"]) {
		NSLog(@"******* error message: %@", string);
	}
}
// -----------------------------------------------------------------------------
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	//	NSLog(@"songs array has %d items", [songs count]);
	
	[theTableView reloadData];
	//	theTableView.tableFooterView.hidden = NO;
	//	
	//	// maybe not the best place for this, but it works well
	//	if ([songs count] >= 75) {
	//		theTableView.tableFooterView.hidden = YES;
	//	}
	[theTableView setHidden:NO];
	//	[bigSpinner stopAnimating];
	
}

@end
