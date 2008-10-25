//
//  audio_testViewController.m
//  audio-test
//
//  Created by Shawn Bernard on 10/19/08.
//  Copyright Nau Inc. 2008. All rights reserved.
//

#import "audio_testViewController.h"
#import "AudioStreamer.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import <CommonCrypto/CommonHMAC.h>

#define API_KEY @"b6075b6c7ec95c4c5ecf"

@implementation audio_testViewController

@synthesize audioButton;
@synthesize blipSearchBar;
@synthesize theTableView;

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


// -----------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
	//[adView loadRequest:[Settings adRequest]];
//	[self loadSongs];
	//[theTableView reloadData];
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
	//const char *strToSign = [[NSString stringWithFormat:@"GET\n%@\n%@", timestamp, nonce] UTF8String];
	//unsigned char *result[CC_SHA1_DIGEST_LENGTH];
	//CCHmac(kCCHmacAlgSHA1, @"brREsLcDUIKVtr%a3AqOWuB3qB0eEL&3rsHj%", CC_SHA1_DIGEST_LENGTH, strToSign, strlen(strToSign), result);
	//NSLog([NSString stringWithCString:result]);
//	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
//									initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.blip.fm/search/findSongs.xml?apiKey=%@&searchTerm=%@&nonce=%@&timestamp=%@", 
//																	  API_KEY, 
//																	  [searchBar.text  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
//																	  nonce,
//																	  timestamp]]];
//	NSLog(@"request: %@", request);
//	NSLog(@"date: %@", [NSDate date]);
//	NSLog(@"time: %d", [NSDate dateWithTimeIntervalSince1970:0]);
//	[request setHTTPMethod:@"GET"];
//	NSString *request_body = [NSString 
//							  stringWithFormat:@"email=%@&password=%@&type=regular&group=%@&title=%@&body=%@",
//							  [email           stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//							  [password        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//							  [accountName        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//							  [nameField.text        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//							  [messageField.text        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
//							  ];
//	[request setHTTPBody:[request_body dataUsingEncoding:NSUTF8StringEncoding]];
	//NSURLDownload *theDownload = [[NSURLDownload alloc] initWithRequest:request delegate:self];
	
	// retrieve the hash from the php page
	NSString *tempurl = [NSString stringWithFormat:@"http://www.literalshore.com/gorloch/blip/encrypt.php?nonce=%@&timestamp=%@", nonce, timestamp];
//	NSURLRequest *temprequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempurl]];
//	NSLog(@"request 1: %@", [NSURLRequest requestWithURL:[NSURL URLWithString:tempurl]]);
//	NSLog(@"request 1: %@", temprequest);
//	
////	NSURL *hashUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.literalshore.com/gorloch/blip/encrypt.php?nonce=%@&timestamp=%@", nonce, timestamp]];
////	NSLog(@"hashurl: %@", hashUrl);
////	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:hashUrl];
////	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:hashUrl];
////	[hashUrl release];
////	NSLog(@"request: ", request); 
////	[request setHTTPMethod:@"GET"];
//	NSLog(@"temprequest: %@", temprequest); 
//	
//	NSURLResponse *response;
//	NSError *error;
//	NSData* result = [NSURLConnection sendSynchronousRequest:temprequest returningResponse:&response error:&error];

	
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

- (IBAction)playAudio:(id)sender {
	NSLog(@"button clicked! HURRAY!");

//	NSURL *url = [NSURL URLWithString:@"http://downloads.pitchforkmedia.com/Tom%20Waits%20-%20Road%20To%20Peace.mp3"];
//	streamer = [[AudioStreamer alloc] initWithURL:url];
//	[streamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
//	[streamer start];
	
	[streamer stop];
	[streamer removeObserver:self forKeyPath:@"isPlaying"];

//	MPMoviePlayerController *controller = [[MPMoviePlayerController alloc] initWithContentURL:url]; 
//	[controller play];
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
//			 withObject:[[NSImageView alloc] initWithString:@"stopbutton"]
//			 waitUntilDone:NO];
		} else {
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
			
//			[self
//			 performSelector:@selector(setButtonImage:)
//			 onThread:[NSThread mainThread]
//			 withObject:[[NSImageView alloc] initWithString:@"playbutton"]
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
	[theTableView release];
	[blipSearchBar release];
	
	[rssParser release];
	[songs release];
	[item release];
	[currentTitle release];
	[currentLocation release];
	[currentArtist release];
	
    [super dealloc];
}
// -----------------------------------------------------------------------------
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
	
	cell.font = [UIFont systemFontOfSize:12.0];
	
	// Set up the cell
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	BlipSong *song = (BlipSong*) [songs objectAtIndex: storyIndex];
	cell.text = song.title;
//	cell.story = story;
//	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}
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
	if (songs == nil) {  // or maybe just check the boolean moreResults.  shouldn't matter much
		songs = [[NSMutableArray alloc] init];
	}
	
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
