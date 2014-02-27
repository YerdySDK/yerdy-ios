//
//  YRDTrackPurchaseResponse.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackPurchaseResponse.h"

@implementation YRDTrackPurchaseResponse

+ (NSDictionary *)jsonMappings
{
	return @{ @"result" : @"result" };
}

+ (NSDictionary *)jsonTypeConversions
{
	return @{
		@"result" : ^id(id input) {
			YRDTrackPurchaseResult result = [input intValue];
			
			// validate the returned integer from the server actually maps to a
			// valid enum value
			if (result == YRDTrackPurchaseResultServerError ||
				result == YRDTrackPurchaseResultSuccess ||
				result == YRDTrackPurchaseResultInvalid ||
				result == YRDTrackPurchaseResultRequestError)
				return @(result);
			else
				return @(YRDTrackPurchaseResultServerError);
		}
	};
}

@end
