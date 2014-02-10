//
//  YRDLog.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRDDefines.h"

typedef enum YRDLogLevel {
	YRDLogSilent = 0,
	YRDLogError,
	YRDLogWarn,
	YRDLogInfo,
} YRDLogLevel;

YRD_EXTERN void YRDSetLogLevel(YRDLogLevel level);

YRD_EXTERN void YRDLog(YRDLogLevel level, NSString *fmt, ...) NS_FORMAT_FUNCTION(2, 3);
YRD_EXTERN void YRDLogv(YRDLogLevel level, NSString *fmt, va_list args);

YRD_EXTERN void YRDError(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);
YRD_EXTERN void YRDWarn(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);
YRD_EXTERN void YRDInfo(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);
