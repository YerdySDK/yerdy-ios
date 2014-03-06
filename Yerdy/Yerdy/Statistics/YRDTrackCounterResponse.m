//
//  YRDTrackCounterResponse.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackCounterResponse.h"

@implementation YRDTrackCounterResponse

+ (NSDictionary *)jsonMappings
{
	return @{
		@"code" : @"result",
		@"value" : @"value",
		@"expire_time" : @"expirationDate"
	};
}

+ (NSDictionary *)jsonTypeConversions
{
	return @{
		@"code" : ^id(id input) {
			if ([input isKindOfClass:[NSNumber class]] && [input isEqualToNumber:@0]) {
				return @(YRDTrackCounterResultSuccess);
			} else if ([input isKindOfClass:[NSString class]] && [input isEqualToString:@"0"]) {
				return @(YRDTrackCounterResultSuccess);
			} else {
				return @(YRDTrackCounterResultFailure);
			}
		},
		@"expire_time" : ^id(id input) {
			if ([input respondsToSelector:@selector(doubleValue)]) {
				double secondsSince1970 = [input doubleValue];
				return [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
			} else {
				return nil;
			}
		},
	};
}

@end
