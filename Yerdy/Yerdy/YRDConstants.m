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
NSString *YRDBaseURL = @"http://services.yerdy.com/";


NSTimeInterval YRDRequestTimeout = 10.0;

NSString *YRDErrorDomain = @"com.yerdy.Error";

NSString *YRDCustomDeviceIDDefaultsKey = @"YRDCustomDeviceID";

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

NSString *YRDProgressionLastEarnedCurrencyDefaultsKey = @"YRDProgressionLastEarnedCurrency";
NSString *YRDProgressionLastPurchasedCurrencyDefaultsKey = @"YRDProgressionLastPurchasedCurrency";
NSString *YRDProgressionLastSpentCurrencyDefaultsKey = @"YRDProgressionLastSpentCurrency";
NSString *YRDProgressionLastItemPurchasesDefaultsKey = @"YRDProgressionLastItemPurchases";
