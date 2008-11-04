//
//  SearchViewController.h
//  SearchViewController
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlipSong.h"

@class AudioStreamer;

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
//	IBOutlet UITextField *textField;
//	IBOutlet UIButton *button;
	AudioStreamer *streamer;
	
	IBOutlet UISearchBar *blipSearchBar;
	IBOutlet UITableView *theTableView;
	
	NSXMLParser *rssParser;
	NSMutableArray *songs;
	
	// a temporary item; added to the "stories" array one at a time, and cleared for the next one
	BlipSong *item;
	
	// it parses through the document, from top to bottom...
	// we collect and cache each sub-element value, and then save each item to our array.
	// we use these to track each current item, until it's ready to be added to the "stories" array
	NSString *currentElement;
	NSMutableString *currentTitle, *currentLocation, *currentArtist;
	
	NSMutableArray *blipPlaylist;
}

@property (nonatomic, retain) IBOutlet UISearchBar *blipSearchBar;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) NSMutableArray *blipPlaylist;

- (void)parseXMLFileAtURL:(NSString *)URL;
- (IBAction)removeModalView:(id)sender;

@end

