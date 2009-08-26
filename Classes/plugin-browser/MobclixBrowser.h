#define kNotificationMobclixBrowserOpen @"MOBCLIX_BROWSER_OPEN"
#define kNotificationMobclixBrowserClose @"MOBCLIX_BROWSER_CLOSE"

@interface MobclixBrowser : NSObject {}

// Open the browser with a request
+ (void) openRequest: (NSURLRequest*) request;

// Close the browser
+ (void) close;

// Shared browser object for identifying notification sender when notifications are posted
+ (id) sharedBrowser;

@end
