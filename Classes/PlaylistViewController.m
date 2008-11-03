//
//  PlaylistViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 11/2/08.
//  Copyright 2008 Nau Inc.. All rights reserved.
//

#import "PlaylistViewController.h"
#import "iPhoneStreamingPlayerAppDelegate.h"
#import "BlipSong.h"

@implementation PlaylistViewController

@synthesize theTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [super viewDidLoad];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
    [super setEditing:editing animated:animated];
    [theTableView setEditing:editing animated:YES];
    if (editing) {
        //addButton.enabled = NO;
    } else {
		//addButton.enabled = YES;
    }	
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //SimpleEditableListAppDelegate *controller = (SimpleEditableListAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[controller removeObjectFromListAtIndex:indexPath.row];
		iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
		[appDelegate.playlist removeObjectAtIndex:indexPath.row];
        [theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];		
    }	
}

//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
//    NSString *stringToMove = [[self.reorderingRows objectAtIndex:sourceIndexPath.row] retain];
//    [self.reorderingRows removeObjectAtIndex:sourceIndexPath.row];
//    [self.reorderingRows insertObject:stringToMove atIndex:destinationIndexPath.row];
//    [stringToMove release];	
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	NSLog(@"inside playlist table. playlist: %@", appDelegate.playlist);
    return [appDelegate.playlist count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	int songIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	BlipSong *song = (BlipSong*) [appDelegate.playlist objectAtIndex: songIndex];
	cell.text = song.title;
	
    return cell;
}


/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
*/

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
*/

#pragma mark Row reordering

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
	   toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
		
	return proposedDestinationIndexPath;
}

// TODO: fix this
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSLog(@"moving row from index %d to index %d", fromIndexPath.row, toIndexPath.row);
	// change the order of the playlist array
	iPhoneStreamingPlayerAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	BlipSong *movedSong = [appDelegate.playlist objectAtIndex:fromIndexPath.row];
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[appDelegate.playlist count]];
	for (int i = 0; i < [appDelegate.playlist count]; i++) {
		NSLog(@"i = %d", i);
		if (i == toIndexPath.row) {
			NSLog(@"i == toIndexPath.row");
			[tmpArray addObject:movedSong];
		} else if (i == fromIndexPath.row) {
			NSLog(@"i == fromIndexPath.row");
			[tmpArray addObject:[appDelegate.playlist objectAtIndex:i+1]];
		} else if (i > fromIndexPath.row && i < toIndexPath.row) {
			[tmpArray addObject:[appDelegate.playlist objectAtIndex:i+1]];
		} else {
			NSLog(@"else");
			[tmpArray addObject:[appDelegate.playlist objectAtIndex:i]];
		}
	}
	appDelegate.playlist = tmpArray;
//	NSUInteger rangeLength = toIndexPath.row - fromIndexPath.row;
//	[appDelegate.playlist replaceObjectsInRange:NSMakeRange(fromIndexPath.row + 1, rangeLength) withObjectsFromArray:appDelegate.playlist range:NSMakeRange(fromIndexPath.row, rangeLength)];
//	[appDelegate.playlist insertObject:movedSong atIndex:toIndexPath.row];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {

	// it would be nice to compare the current size of the table to the size of the playlist
	// but I can't seem to find a programmatic way to determine how many rows are being displayed
	[theTableView reloadData];
	
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc {
	[theTableView release];
	
    [super dealloc];
}


@end

