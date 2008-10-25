//
//  audio_testViewController.h
//  audio-test
//
//  Created by Shawn Bernard on 10/19/08.
//  Copyright Nau Inc. 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlipSong.h"

@class AudioStreamer;

@interface audio_testViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UIButton *audioButton;
	IBOutlet UISearchBar *blipSearchBar;
	IBOutlet UITableView *theTableView;
	AudioStreamer *streamer;
	
	NSXMLParser *rssParser;
	NSMutableArray *songs;
	
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	BlipSong *item;
	
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString *currentElement;
	NSMutableString *currentTitle, *currentLocation, *currentArtist;
}
@property (nonatomic, retain) IBOutlet UIButton *audioButton;
@property (nonatomic, retain) IBOutlet UISearchBar *blipSearchBar;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;

- (void)parseXMLFileAtURL:(NSString *)URL;
- (IBAction)playAudio:(id)sender;

@end

