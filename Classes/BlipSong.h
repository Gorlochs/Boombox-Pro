//
//  BlipSong.h
//  audio-test
//
//  Created by Shawn Bernard on 10/24/08.
//  Copyright 2008 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BlipSong : NSObject {
	NSString *title;
	NSString *location;
	NSString *artist;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *artist;

@end
