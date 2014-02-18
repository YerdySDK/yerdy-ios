//
//  YRDConstants.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define YRD_COMPILING_FOR_IOS_7 1
#endif


extern NSString *YRDBaseURL;
extern NSTimeInterval YRDRequestTimeout;

extern NSString *YRDErrorDomain;
enum YRDErrorCodes {
	// 4xx and 5xx map to corresponding HTTP status codes
	
	YRDJSONError = 2000,
};

extern NSString *YRDAppVersionDefaultsKey;
extern NSString *YRDLaunchesDefaultsKey;
extern NSString *YRDResumesDefaultsKey;
extern NSString *YRDExitsDefaultsKey;

extern NSString *YRDPushTokenDefaultsKey;

extern NSString *YRDTimePlayedDefaultsKey;