//
//  YRDLaunchResponse.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDLaunchResponse.h"

@implementation YRDLaunchResponse

+ (NSDictionary *)jsonMappings
{
	return @{
		@"success" : @"success",
		@"type" : @"userType",
		@"tag" : @"tag",
		@"timestamp" : @"timestamp",
	};
}

+ (NSDictionary *)jsonTypeConversions
{
	return @{
			 @"success" : ^id(id input) {
				 return @([input boolValue]);
			 },
			 @"type" : ^id(id input) {
				 if ([input isEqual:@"none"]) return @(YRDUserTypeNone);
				 else if ([input isEqual:@"cheat"]) return @(YRDUserTypeCheat);
				 else if ([input isEqual:@"pay"]) return @(YRDUserTypePay);
				 return @(YRDUserTypeNone);
			 },
			 @"timestamp" : ^id(id input) {
				 return [NSDate dateWithTimeIntervalSince1970:[input doubleValue]];
			 },
	};
}

@end
