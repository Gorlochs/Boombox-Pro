//Mobclix Library Version 2.0.0
#import <CoreLocation/CoreLocation.h>

#define MOBCLIX_APPLICATION_PROCESS @"MOBCLIX_APPLICATION_PROCESS"
#define MOBCLIX_APPLICATION_EVENT	@"MOBCLIX_APPLICATION_EVENT"

typedef enum{
	LOG_LEVEL_DEBUG =	1 << 0,
	LOG_LEVEL_INFO	=	1 << 1,
	LOG_LEVEL_WARN	=	1 << 2,
	LOG_LEVEL_ERROR	=	1 << 3,
	LOG_LEVEL_FATAL =	1 << 4
} MobclixLogLevel;

@interface Mobclix : NSObject {
}

// Initialize Mobclix. Should be called in your AppDelegate's applicationDidFinishLaunching: method
+ (void) start;

// Log a custom event.
+ (void) logEventWithLevel: (MobclixLogLevel) logLevel
			   processName: (NSString*) processName
				 eventName: (NSString*) eventName
			   description: (NSString*) description
					  stop: (BOOL) stopProcess;

// Sync event logs.
+ (void) sync;

// Manually update location.
+ (void) updateLocation: (CLLocation*) location;

@end

