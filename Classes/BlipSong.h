//
//  BlipSong.h
//  audio-test
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface BlipSong : NSObject {
	// Opaque reference to the underlying database.
    sqlite3 *database;
	
	NSInteger songId;
	NSString *title;
	NSString *location;
	NSString *artist;
    NSInteger failCount;
}

@property (nonatomic, assign, readonly) NSInteger songId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, assign) NSInteger failCount;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (void)insertIntoDatabase:(sqlite3 *)db;
+ (void)finalizeStatements;
- (NSString*)constructTitleArtist;

@end
