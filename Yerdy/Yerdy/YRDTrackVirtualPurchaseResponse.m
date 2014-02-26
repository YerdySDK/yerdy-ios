//
//  YRDTrackVirtualPurchaseResponse.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackVirtualPurchaseResponse.h"

@implementation YRDTrackVirtualPurchaseResponse

+ (NSDictionary *)jsonMappings
{
	return @{ @"result" : @"result" };
}

+ (NSDictionary *)jsonTypeConversions
{
	return @{
		@"result" : ^id(id input) {
			YRDTrackVirtualPurchaseResult result = [input intValue];
			
			// validate the returned integer from the server actually maps to a
			// valid enum value
			if (result == YRDTrackVirtualPurchaseResultError ||
				result == YRDTrackVirtualPurchaseResultSuccess ||
				result == YRDTrackVirtualPurchaseResultInvalid)
				return @(result);
			else
				return @(YRDTrackVirtualPurchaseResultError);
		}
	};
}

@end
