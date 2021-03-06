//
//  YRDConstants.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
#define YRD_COMPILING_FOR_IOS_8 1
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define YRD_COMPILING_FOR_IOS_7 1
#endif

#define YRD_IS_4_INCH_RETINA() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0)


extern NSString *YRDBaseURL;
extern NSTimeInterval YRDRequestTimeout;

extern NSString *YRDErrorDomain;
enum YRDErrorCodes {
	// 4xx and 5xx map to corresponding HTTP status codes
	
	YRDJSONError = 2000,
};

extern NSString *YRDCustomDeviceIDDefaultsKey;

extern NSString *YRDInitialLaunchCompletedDefaultsKey;

extern NSString *YRDAppVersionDefaultsKey;
extern NSString *YRDTotalLaunchesDefaultsKey;
extern NSString *YRDVersionLaunchesDefaultsKey;
extern NSString *YRDVersionResumesDefaultsKey;
extern NSString *YRDVersionExitsDefaultsKey;
extern NSString *YRDLastCrashCountKey;

extern NSString *YRDUserTypeDefaultsKey;

extern NSString *YRDPushTokenDefaultsKey;
extern NSString *YRDABTagDefaultsKey;

// See YRDTimeTracker
extern NSString *YRDTimePlayedDefaultsKey;
extern NSString *YRDMinutesPlayedDefaultsKey;
extern NSString *YRDVersionStartTimeOffsetDefaultsKey;

// See YRDScreenVisitTracker
extern NSString *YRDScreenVisitsDefaultsKey;

// See YRDAdRequestTracker
extern NSString *YRDAdRequestsDefaultsKey;
extern NSString *YRDAdFillsDefaultsKey;

// See Yerdy
extern NSString *YRDAppliedExistingCurrencyDefaultsKey;
extern NSString *YRDIsUserExistingUserDefaultsKey;

extern NSString *YRDEarnedCurrencyDefaultsKey;
extern NSString *YRDSpentCurrencyDefaultsKey;
extern NSString *YRDPurchasedCurrencyDefaultsKey;

extern NSString *YRDItemsPurchasedDefaultsKey;
extern NSString *YRDItemsPurchasedSinceInAppDefaultsKey;

// See YRDProgressionTracker - Progression events
extern NSString *YRDProgressionCategoryMilestonesDefaultsKeyFormat;

// See YRDProgressionTracker - Time events
extern NSString *YRDProgressionLastEarnedCurrencyDefaultsKey;
extern NSString *YRDProgressionLastPurchasedCurrencyDefaultsKey;
extern NSString *YRDProgressionLastSpentCurrencyDefaultsKey;
extern NSString *YRDProgressionLastItemPurchasesDefaultsKey;

// see YRDHistoryTracker
extern NSString *YRDHistoryItemsKeyFormat;

// see YRDFeatureMasteryTracker
extern NSString *YRDFeatureMasteryCountsFormat;
extern NSString *YRDFeatureMasterySubmittedFormat;
