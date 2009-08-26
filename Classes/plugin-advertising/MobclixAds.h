//AdViewDelegate
@protocol MobclixAdViewDelegate;
@class MobclixAdView;

#pragma mark MobclixAdView Abstract Class
// Abstract Ad View - Should not be instantiated directly.
@interface MobclixAdView : UIWebView <UIWebViewDelegate> {
	id delegate;
	NSTimeInterval refreshTime;
	
@private
	NSString *			_adCode;
	NSString *			_adSize;
	NSTimer	*			_adTimer;
	NSURLConnection*	_connection;
	NSMutableData*		_data;
	NSURLResponse*		_response;
}

@property(nonatomic, assign) id<MobclixAdViewDelegate> delegate;
@property(nonatomic, assign) NSTimeInterval refreshTime;

- (void) getAd;
- (void) cancelAd;

@end

#pragma mark MobclixAdView Subclasses

// MMA X-Large Banner 300x50
@interface MMABannerXLAdView : MobclixAdView {}
@end

// IAB Medium Rectangle 300x250
@interface IABRectangleMAdView : MobclixAdView {}
@end

#pragma mark MobclixAdViewDelegate Protocol
@protocol MobclixAdViewDelegate <NSObject>

@optional
 
/*******************************************************************************
 MobclixAdView Status Methods
 ******************************************************************************/

- (void) adViewDidFinishLoad:(MobclixAdView *) adView;
- (void) adViewDidFailLoad: (MobclixAdView *) adView;
- (BOOL) adViewShouldTouchThrough: (MobclixAdView *) adView;
- (void) adViewDidFinishTouchThrough: (MobclixAdView *) adView;

/*******************************************************************************
 Optional Targeting Parameters
 ******************************************************************************/

- (NSString*)	areaCode;
- (NSString*)	postalCode; 

// M or F
- (NSString*)	gender;

// Closest date possible
- (NSDate*)		dateOfBirth;

// In Local Currency
- (NSUInteger)	income;			

/* 
 * 0 - Unknown
 * 1 - High School
 * 2 - Some College
 * 3 - In College
 * 4 - Bachelors Degree
 * 5 - Masters Degree
 * 6 - Doctoral Degree
 */
- (NSUInteger)	education;		

/* 
 * 0 - Unknown
 * 1 - Mixed
 * 2 - Asian
 * 3 - Black
 * 4 - Hispanic
 * 5 - Native American
 * 6 - White
 */
- (NSUInteger)	ethnicity;

// Search String or Contextual Keywords
- (NSString*)	keywords;

@end