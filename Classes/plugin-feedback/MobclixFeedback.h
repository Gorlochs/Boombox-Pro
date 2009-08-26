typedef enum  {
	RATING_NONE			= 0,
	RATING_POOR			= 1,
	RATING_FAIR			= 2,
	RATING_GOOD			= 3,
	RATING_VERY_GOOD	= 4,
	RATING_EXCELLENT	= 5
} MobclixRating;

@interface MobclixFeedback : NSObject {}

// Send back qualitative feedback
+ (void) comment: (NSString*)comment;

// Send back quantitative feedback
+ (void) ratingWithUsability: (MobclixRating)usability
				  appearance: (MobclixRating)appearance
						 fun: (MobclixRating)fun					
					   value: (MobclixRating)value
			  recommendation: (MobclixRating)recommendation
				 performance: (MobclixRating)performance
					 overall: (MobclixRating)overall;

@end
