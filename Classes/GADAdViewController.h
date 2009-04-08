//
//  GADAdViewController.h
//  Google Ads iPhone publisher SDK.
//  Version: 2.0
//
//  Copyright 2009 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GADAdViewControllerDelegate;

typedef struct {
  NSUInteger width;
  NSUInteger height;
} GADAdSize;

// Supported ad size.
static GADAdSize const kGADAdSize320x50 = { 320, 50 };

// Ad click actions
typedef enum {
  // Launch the advertiser's website in Safari
  GAD_ACTION_LAUNCH_SAFARI,
  // Display the advertiser's website in the app (as a subview of the window)
  GAD_ACTION_DISPLAY_INTERNAL_WEBSITE_VIEW,
  // Pass back a UIViewController for displaying the advertiser's website
  GAD_ACTION_DELEGATE_WEBSITE_VIEW,
} GADAdClickAction;

// AdSense ad types
extern NSString* const kGADAdSenseTextAdType;
extern NSString* const kGADAdSenseImageAdType;
extern NSString* const kGADAdSenseTextImageAdType;

///////////////////////////////////////////////////////////////////////////////
// AdSense ad attributes
///////////////////////////////////////////////////////////////////////////////

// Google AdSense client ID (required).
extern NSString* const kGADAdSenseClientID;

// Keywords to target the ad. Defaults to none. Use "," to separate multiple
// keywords and "+" to separate multiple words in a phrase, e.g.
// "car+insurance,car+loans".
extern NSString* const kGADAdSenseKeywords;

// Channel IDs. Channels are optional but strongly recommended. Specify up to
// five custom channels to track the performance of this ad unit.
extern NSString* const kGADAdSenseChannelIDs;  // NSArray

// Ad type is text or image (default is kGADAdSenseTextImageAdType)
extern NSString* const kGADAdSenseAdType;

// Indicates whether this is a test ad request. Defaults to 1. When you are
// done testing, contact us so that we can review your test app. If everything
// looks good, then you can set to 0.
extern NSString* const kGADAdSenseIsTestAdRequest;  // NSNumber

// If your app content is loaded from iPhone-customized web page content, set
// kGADAdSenseAppWebContentURL to the iPhone-customized web content URL, e.g.
// www.google.com.
extern NSString* const kGADAdSenseAppWebContentURL;

// The default background color of the ad is FFFFFF.
extern NSString* const kGADAdSenseAdBackgroundColor;  // UIColor

// The default border color of the ad is 334466.
extern NSString* const kGADAdSenseAdBorderColor;  // UIColor

// The default color of the hyperlinked title of the ad is 0000FF.
extern NSString* const kGADAdSenseAdLinkColor;  // UIColor

// The default color of the ad description is 000000.
extern NSString* const kGADAdSenseAdTextColor;  // UIColor

// The default color of the ad url is 009900.
extern NSString* const kGADAdSenseAdURLColor;  // UIColor

// When there are no targeted Google ads to show, Google displays public service
// ads. You can override this behavior by setting kGADAdsenseAlternateAdColor
// to a color that is used to fill in the ad slot.
extern NSString* const kGADAdSenseAlternateAdColor;  // UIColor
extern NSURL* const kGADAdSenseAlternateAdURL;  // NSURL

///////////////////////////////////////////////////////////////////////////////
// DoubleClick ad attributes
///////////////////////////////////////////////////////////////////////////////

// Keyname (required). Example site/zone;kw=keyword;key=value;sz=300x50
extern NSString* const kGADDoubleClickKeyName;

// Size profile. 'xl' - extra large. 'l' - large. 'm' - medium. 's' - small.
// 't' - text. Defaults to 'xl'.
extern NSString* const kGADDoubleClickSizeProfile;

// Override the DoubleClick country. By default, the phone's country setting
// is used to determine the closest DoubleClick servers. Valid values: us, uk,
// fr, jp.
extern NSString* const kGADDoubleClickCountryOverride;

// Background color (used if the ad creative is smaller than the GADAdSize).
// Defaults to FFFFFF.
extern NSString* const kGADDoubleClickBackgroundColor;

///////////////////////////////////////////////////////////////////////////////
// View controller for displaying an ad
///////////////////////////////////////////////////////////////////////////////
typedef struct __GADAdViewControllerPrivate GADAdViewControllerPrivate;

@interface GADAdViewController : UIViewController <UIWebViewDelegate> {
 @private
  GADAdViewControllerPrivate *private_;
}

@property(nonatomic, assign) GADAdSize adSize;  // default: kGADAdSize320x50
@property(nonatomic, assign) id<GADAdViewControllerDelegate> delegate;

// Initialize and pass the application delegate
- (id)initWithDelegate:(id<GADAdViewControllerDelegate>)delegate;

// Load an ad by specifying AdSense or DoubleClick ad attributes
- (void)loadGoogleAd:(NSDictionary *)attributes;

// Dismiss the website view
- (void)dismissWebsiteView;

@end

///////////////////////////////////////////////////////////////////////////////
// Delegate for receiving GADAdViewController messages
///////////////////////////////////////////////////////////////////////////////
@protocol GADAdViewControllerDelegate <NSObject>
@optional

// Invoked when the ad load completes
- (void)adControllerDidFinishLoading:(GADAdViewController *)adController;

// Invoked if the ad load fails
- (void)adController:(GADAdViewController *)adController
     failedWithError:(NSError *)error;

// |adControllerActionModelForAdClick:| will be called when a user taps on an
// ad. The delegate can override the default behavior (opening in Safari).
- (GADAdClickAction)adControllerActionModelForAdClick:
    (GADAdViewController *)adController;

// This method is called by |GADAdViewController| if
// |adControllerActionModelForAdClick| returns
// GAD_ACTION_DELEGATE_WEBSITE_VIEW. The responder is responsible for retaining
// and displaying the websiteViewController's view. This allows you to have
// finer control over how the view is displayed.
- (void)adController:(GADAdViewController *)adController
    delegateWebsiteView:(UIViewController *)websiteViewController;

@end
