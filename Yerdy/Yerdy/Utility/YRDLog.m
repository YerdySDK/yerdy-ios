//
//  YRDLog.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDLog.h"

static YRDLogLevel logLevel = YRDLogWarn;


static NSString *YRDStringForLogLevel(YRDLogLevel level)
{
	switch (level) {
		case YRDLogError: return @"ERROR";
		case YRDLogWarn: return @"WARNING";
		case YRDLogInfo: return @"INFO";
		case YRDLogDebug: return @"DEBUG";
		case YRDLogSilent: return nil; // never used for logging
	}
	return nil;
}


void YRDSetLogLevel(YRDLogLevel level)
{
	logLevel = level;
}

YRDLogLevel YRDGetLogLevel()
{
	return logLevel;
}

void YRDLogv(YRDLogLevel level, NSString *fmt, va_list args)
{
	if (level <= logLevel) {
		fmt = [NSString stringWithFormat:@"[%@] Yerdy: %@", YRDStringForLogLevel(level), fmt];
		NSLogv(fmt, args);
	}
}

void YRDLog(YRDLogLevel level, NSString *fmt, ...)
{
	va_list list;
	va_start(list, fmt);
	YRDLogv(level, fmt, list);
	va_end(list);
}

void YRDError(NSString *fmt, ...)
{
	va_list list;
	va_start(list, fmt);
	YRDLogv(YRDLogError, fmt, list);
	va_end(list);
}

void YRDWarn(NSString *fmt, ...)
{
	va_list list;
	va_start(list, fmt);
	YRDLogv(YRDLogWarn, fmt, list);
	va_end(list);
}

void YRDInfo(NSString *fmt, ...)
{
	va_list list;
	va_start(list, fmt);
	YRDLogv(YRDLogInfo, fmt, list);
	va_end(list);
}

void YRDDebug(NSString *fmt, ...)
{
	va_list list;
	va_start(list, fmt);
	YRDLogv(YRDLogDebug, fmt, list);
	va_end(list);
}
