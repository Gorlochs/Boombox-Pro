//
//  iPhoneStreamingPlayerAppDelegate.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "iPhoneStreamingPlayerAppDelegate.h"
#import "BlipSong.h"

// Private interface for AppDelegate - internal only methods.
@interface iPhoneStreamingPlayerAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;
- (void)clearDatabase;
- (void)displayNetworkAlert:(NSString*)msg;
@end

@implementation iPhoneStreamingPlayerAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize remoteHostStatus;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	audioManager = [AudioManager sharedAudioManager];
    
    [self createEditableCopyOfDatabaseIfNeeded];
    [self initializeDatabase];

    // Override point for customization after app launch
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	application.statusBarOrientation = UIInterfaceOrientationLandscapeRight;
	
	[[Reachability sharedReachability] setHostName:@"www.blip.fm"];
	
	// Query the SystemConfiguration framework for the state of the device's network connections.
	self.remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];

	switch (self.remoteHostStatus) {
		case NotReachable: {
			[self displayNetworkAlert:@"You are currently do not have an internet connection.  You will not have acces to playing any songs until you reconnect."];
			break;
		}
		case ReachableViaCarrierDataNetwork: {
			[self displayNetworkAlert:@"Hi, welcome to BoomBox. Please use a WiFi connection where available to improve performance and reduce network bandwidth."];
			break;
		}
		case ReachableViaWiFiNetwork:
			break;
		default:
			break;
	}
}

- (void) displayNetworkAlert:(NSString*)msg {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boombox" 
													message:msg
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self clearDatabase];
	for (id song in audioManager.playlist) {
		[song insertIntoDatabase:database];
	}
	[BlipSong finalizeStatements];
    // Close the database.
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"boombox.sql"];
    success = [fileManager fileExistsAtPath:writableDBPath];
	NSLog(@"writableDBPath: %@", writableDBPath);
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"boombox.sql"];
	NSLog(@"default db path: %@", defaultDBPath);
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {
	NSLog(@"initializing database...");
    NSMutableArray *songz = [[NSMutableArray alloc] init];
    audioManager.playlist = songz;
    [songz release];
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"boombox.sql"];
	NSLog(@"db path: %@", path);
	
	
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		NSLog(@"sqlite db found...");
        // Get the primary key for all songs.
        const char *sql = "SELECT pk FROM playlist";
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			NSLog(@"statement prepared...");
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                // The second parameter indicates the column index into the result set.
                int primaryKey = sqlite3_column_int(statement, 0);
                // We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
                // autorelease is slightly more expensive than release. This design choice has nothing to do with
                // actual memory management - at the end of this block of code, all the book objects allocated
                // here will be in memory regardless of whether we use autorelease or release, because they are
                // retained by the books array.
				BlipSong *song = [[BlipSong alloc] initWithPrimaryKey:primaryKey database:database];
                [audioManager.playlist addObject:song];
				NSLog(@"initialized playlist from the database: %@", audioManager.playlist);
                [song release];
            }
        } else {
			NSLog(@"something went wrong. statement: %@", statement);
		}
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

- (void)clearDatabase {
	// This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
	const char *sql = "DELETE FROM playlist";
	sqlite3_stmt *statement;
	// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
	// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
		int success = sqlite3_step(statement);
		if (success) {
			NSLog(@"delete executed...");
		} 
		// We "step" through the results - once for each row.
		//while (sqlite3_step(statement) == SQLITE_ROW) {
//			// The second parameter indicates the column index into the result set.
//			int primaryKey = sqlite3_column_int(statement, 0);
//			// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
//			// autorelease is slightly more expensive than release. This design choice has nothing to do with
//			// actual memory management - at the end of this block of code, all the book objects allocated
//			// here will be in memory regardless of whether we use autorelease or release, because they are
//			// retained by the books array.
//			BlipSong *song = [[BlipSong alloc] initWithPrimaryKey:primaryKey database:database];
//			[playlist addObject:song];
//			NSLog(@"initialized playlist from the database: %@", playlist);
//			[song release];
//		}
	} else {
		NSLog(@"something went wrong. statement: %@", statement);
	}
	// "Finalize" the statement - releases the resources associated with the statement.
	sqlite3_finalize(statement);
    // All data for the book is already in memory, but has not be written to the database
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory
    //hydrated = YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // "dehydrate" all data objects - flushes changes back to the database, removes objects from memory
    //[playlist makeObjectsPerformSelector:@selector(dehydrate)];
}

@end
