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
	};
}

+ (NSDictionary *)jsonTypeConversions
{
	return @{
			 @"success" : (id(^)(id))^(id input) {
				 return @([input boolValue]);
			 },
	};
}

@end
