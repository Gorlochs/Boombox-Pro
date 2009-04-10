//
//  iPhoneStreamingPlayerAppDelegate.m
//  iPhoneStreamingPlayer
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "iPhoneStreamingPlayerAppDelegate.h"
#import "BlipSong.h"
#import "AudioManager.h"
#import "Beacon.h"

//static sqlite3_stmt *insert_statement = nil;

// Private interface for AppDelegate - internal only methods.
@interface iPhoneStreamingPlayerAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;
- (void)clearDatabase;
- (void)displayNetworkAlert:(NSString*)msg;
- (void)reachabilityChanged:(NSNotification *)note;
- (void)updateStatus;
- (NSString*)getCountryCode;
- (void)checkForEmergencyMessage;
- (void)checkForUpgradeMessage;
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
	[[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
	
	// Query the SystemConfiguration framework for the state of the device's network connections.
	//[self updateStatus];
	self.remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
	
	[self checkForEmergencyMessage];
	[self checkForUpgradeMessage];
	
	// set observer to update the network status as it changes
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
	
	// testing.  this should be utilized in v1.0.2
	//[self getCountryCode];

    NSString *applicationCode = @"51512b37fa78552a6981778e1e652682";
    [Beacon initAndStartBeaconWithApplicationCode:applicationCode useCoreLocation:YES useOnlyWiFi:NO];
}

- (NSString*)getCountryCode {
	NSLocale *locale = [NSLocale currentLocale];
	NSString *code;
	if (locale) {
		code = [locale objectForKey:NSLocaleCountryCode];
		NSLog(@"country code: %@", code);
	}
	return code;
}

- (void)reachabilityChanged:(NSNotification *)note {
	NSLog(@"update status called...");
    [self updateStatus];
}

- (void)updateStatus {
	// Query the SystemConfiguration framework for the state of the device's network connections.
	self.remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
	NSLog(@"remote host status (0 = unreachable; 1 = cell network, 2 = wifi): %d", self.remoteHostStatus);
	
	switch (self.remoteHostStatus) {
		case NotReachable: {
			[self displayNetworkAlert:@"You currently do not have a WiFi connection. Please reconnect in order to resume playing music."];
			[audioManager stopStreamer];
			break;
		}
		case ReachableViaCarrierDataNetwork: {
			[self displayNetworkAlert:@"In order to play songs, please connect to a WiFi network. You may still search and add songs to your playlist."];
			[audioManager stopStreamer];
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

- (void) checkForEmergencyMessage {
	
	NSString *emergencyMessage = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.literalshore.com/gorloch/blip/messages/boombox.1.1.3.emergency.message"]];
	if (emergencyMessage != nil && ![emergencyMessage isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boombox Message" 
														message:emergencyMessage
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];	
	}
}

- (void) checkForUpgradeMessage {
	
    NSInteger msgCount =  [[[NSUserDefaults standardUserDefaults] stringForKey:@"upgradeMessageCount"] intValue];
	NSString *upgradeUrl = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.literalshore.com/gorloch/blip/messages/boombox.lite.upgrade.message"]];
	NSString *upgradeMessage = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.literalshore.com/gorloch/blip/messages/boombox.lite.upgrade.real.message"]];
    if (upgradeUrl != nil && ![upgradeUrl isEqualToString:@""] && msgCount < 4) {
        [[NSUserDefaults standardUserDefaults] setInteger:msgCount+1 forKey:@"upgradeMessageCount"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boombox Message" 
														message:upgradeMessage
													   delegate:self 
											  cancelButtonTitle:@"No Thanks" 
											  otherButtonTitles:@"Upgrade!",nil];
		[alert show];
		[alert release];	
	}
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *emergencyMessage = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.literalshore.com/gorloch/blip/messages/boombox.lite.upgrade.url"]];
    if (buttonIndex == 1) {
        NSLog(@"custom button has been clicked");
        [[Beacon shared] startSubBeaconWithName:@"Upgrade Clicked" timeSession:NO];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emergencyMessage]];
    }
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
	
    [[Beacon shared] endBeacon];
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
		
		// FIRST TABLE INITIALIZATION
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
		
//		// *** used for counting songs for limiting cell network access ***
//		// All this stuff is to initalize the number of songs a user has played on the cell network
//		// We have to do this in order to limit the bandwidth while the user is on a cell network
//		NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
//		[outputFormatter setDateFormat:@"yyyy-MM-dd"];
//		NSString *today = [outputFormatter stringFromDate:[NSDate date]];
//		//NSLog(@"today: %@", today);
//		
//		NSString *sqlQuery = [NSString stringWithFormat:@"SELECT pk, count, date_played FROM cell_network_song_count WHERE date_played = '%@'", today];
//		const char *sql2 = [sqlQuery cStringUsingEncoding:NSASCIIStringEncoding];
//        sqlite3_stmt *statement2;
//		// this SQL is to keep track of the number of cell network songs that are played
//		if (sqlite3_prepare_v2(database, sql2, -1, &statement2, NULL) == SQLITE_OK) {
//			NSLog(@"statement2 prepared...");
//			// We "step" through the results - once for each row.
//			int primaryKey2 = -1;
//			while (sqlite3_step(statement2) == SQLITE_ROW) {
//				// The second parameter indicates the column index into the result set.
//				primaryKey2 = sqlite3_column_int(statement2, 0);
//				audioManager.numberOfSongsPlayedTodayOnCellNetwork = sqlite3_column_int(statement2, 1);
//				
//				NSLog(@"pk: %d", primaryKey2);
//				NSLog(@"date: %@", [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement2, 2)]);
//			}
//			if (primaryKey2 == -1) {
//				// create entry and set session var to 0
//				static char *sql = "INSERT INTO cell_network_song_count (count, date_played) VALUES(0, ?)";
//				if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
//					NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
//				}
//				sqlite3_bind_text(insert_statement, 1, [today cStringUsingEncoding:NSASCIIStringEncoding], -1, SQLITE_TRANSIENT);
//				int success = sqlite3_step(insert_statement);
//				sqlite3_reset(insert_statement);
//				audioManager.numberOfSongsPlayedTodayOnCellNetwork = 0;
//				if (success == SQLITE_ERROR) {
//					NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
//				}
//			}
//			NSLog(@"primaryKey2: %d", primaryKey2);
//		} else {
//			NSLog(@"something went wrong 2. statement: %@", statement2);
//		}
		
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
