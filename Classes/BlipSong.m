//
//  BlipSong.m
//  audio-test
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import "BlipSong.h"

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *hydrate_statement = nil;
static sqlite3_stmt *dehydrate_statement = nil;

@implementation BlipSong

@synthesize songId;
@synthesize title;
@synthesize location;
@synthesize artist;
@synthesize failCount;

- (NSString*)constructTitleArtist {
	return [NSString stringWithFormat:@"%@ - %@", [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], [artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) {
        sqlite3_finalize(insert_statement);
        insert_statement = nil;
    }
    if (init_statement) {
        sqlite3_finalize(init_statement);
        init_statement = nil;
    }
    if (delete_statement) {
        sqlite3_finalize(delete_statement);
        delete_statement = nil;
    }
    if (hydrate_statement) {
        sqlite3_finalize(hydrate_statement);
        hydrate_statement = nil;
    }
    if (dehydrate_statement) {
        sqlite3_finalize(dehydrate_statement);
        dehydrate_statement = nil;
    }
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {
    if (self = [super init]) {
        songId = pk;
        database = db;
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT title, location, artist FROM playlist WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, songId);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
            self.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
            self.location = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)];
            self.artist = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)];
        } else {
            self.title = @"No title";
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
        //dirty = NO;
    }
    return self;
}

- (void)insertIntoDatabase:(sqlite3 *)db {
    database = db;
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO playlist (title, location, artist) VALUES(?,?,?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement, 1, [title UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 2, [location UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 3, [artist UTF8String], -1, SQLITE_TRANSIENT);
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    } else {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        songId = sqlite3_last_insert_rowid(database);
    }
    // All data for the book is already in memory, but has not be written to the database
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory
    //hydrated = YES;
}

- (void) dealloc {	
	[title release];
	[location release];
	[artist release];
	[super dealloc];
}

@end
