//
//  YRDConstants.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDConstants.h"

// Base URL should end in '/', as we use RFC 1808 to determine the full URL
// Production server: http://services.yerdy.com/
// Internal test server:  http://10.189.165.237/~michal/
// Klaus test server: http://10.189.165.104/~krubba/FluikServices/httpdocs/
// Klaus test server (Mac mini): http://10.189.165.234/~user/FluikServices/httpdocs/
// Darren test server: http://10.189.165.207/~darrenclark/FluikServices/httpdocs/
NSString *YRDBaseURL = @"http://10.189.165.234/~user/FluikServices/httpdocs/";


NSTimeInterval YRDRequestTimeout = 10.0;

NSString *YRDErrorDomain = @"com.yerdy.Error";

NSString *YRDCustomDeviceIDDefaultsKey = @"YRDCustomDeviceID";

NSString *YRDInitialLaunchCompletedDefaultsKey = @"YRDInitialLaunchCompleted";

NSString *YRDAppVersionDefaultsKey = @"YRDLastKnownAppVersion";
NSString *YRDTotalLaunchesDefaultsKey = @"YRDTotalLaunchCount";
NSString *YRDVersionLaunchesDefaultsKey = @"YRDVersionLaunchCount";
NSString *YRDVersionResumesDefaultsKey = @"YRDVersionResumeCount";
NSString *YRDVersionExitsDefaultsKey = @"YRDVersionExitCount";

NSString *YRDUserTypeDefaultsKey = @"YRDUserType";

NSString *YRDPushTokenDefaultsKey = @"YRDPushToken";
NSString *YRDABTagDefaultsKey = @"YRDABTag";

NSString *YRDTimePlayedDefaultsKey = @"YRDTimePlayed";
NSString *YRDMinutesPlayedDefaultsKey = @"YRDMinutesPlayed";
NSString *YRDVersionStartTimeOffsetDefaultsKey = @"YRDVersionStartTimeOffset";

NSString *YRDScreenVisitsDefaultsKey = @"YRDScreenVisits";

NSString *YRDAdRequestsDefaultsKey = @"YRDAdRequests";
NSString *YRDAdFillsDefaultsKey = @"YRDAdFills";

NSString *YRDAppliedExistingCurrencyDefaultsKey = @"YRDAppliedExistingCurrency";
NSString *YRDIsUserExistingUserDefaultsKey = @"YRDIsUserExistingUser";

NSString *YRDEarnedCurrencyDefaultsKey = @"YRDEarnedCurrency";
NSString *YRDSpentCurrencyDefaultsKey = @"YRDSpentCurrency";
NSString *YRDPurchasedCurrencyDefaultsKey = @"YRDPurchasedCurrency";

NSString *YRDItemsPurchasedDefaultsKey = @"YRDItemsPurchased";
NSString *YRDItemsPurchasedSinceInAppDefaultsKey = @"YRDItemsPurchasedSinceInApp";

NSString *YRDProgressionCategoryMilestonesDefaultsKeyFormat = @"YRDProgressionCategoryMilestone:%@";

NSString *YRDProgressionLastEarnedCurrencyDefaultsKey = @"YRDProgressionLastEarnedCurrency";
NSString *YRDProgressionLastPurchasedCurrencyDefaultsKey = @"YRDProgressionLastPurchasedCurrency";
NSString *YRDProgressionLastSpentCurrencyDefaultsKey = @"YRDProgressionLastSpentCurrency";
NSString *YRDProgressionLastItemPurchasesDefaultsKey = @"YRDProgressionLastItemPurchases";

NSString *YRDHistoryItemsKeyFormat = @"YRDHistoryItems:%@";
