//
//  YRDConstants.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDConstants.h"

// Base URL should end in '/', as we use RFC 1808 to determine the full URL
NSString *YRDBaseURL = @"http://10.189.165.142/~michal/";
NSTimeInterval YRDRequestTimeout = 10.0;

NSString *YRDErrorDomain = @"com.yerdy.Error";

NSString *YRDCustomDeviceIDDefaultsKey = @"YRDCustomDeviceID";

NSString *YRDAppVersionDefaultsKey = @"YRDLastKnownAppVersion";
NSString *YRDLaunchesDefaultsKey = @"YRDLaunchCount";
NSString *YRDResumesDefaultsKey = @"YRDResumeCount";
NSString *YRDExitsDefaultsKey = @"YRDExitCount";

NSString *YRDPushTokenDefaultsKey = @"YRDPushToken";
NSString *YRDABTagDefaultsKey = @"YRDABTag";

NSString *YRDTimePlayedDefaultsKey = @"YRDTimePlayed";
NSString *YRDMinutesPlayedDefaultsKey = @"YRDMinutesPlayed";