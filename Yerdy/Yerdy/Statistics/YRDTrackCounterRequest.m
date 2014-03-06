//
//  YRDTrackCounterRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackCounterRequest.h"
#import "YRDJSONResponseHandler.h"
#import "YRDTrackCounterResponse.h"
#import "YRDUtil.h"


@implementation YRDTrackCounterRequest

+ (instancetype)requestWithCounterName:(NSString *)name
								 value:(NSString *)value
							 increment:(int)valueIncrement
							parameters:(NSDictionary *)parameters
				   parameterIncrements:(NSDictionary *)parameterIncrements
{
	NSMutableDictionary *query = [@{
		@"name" : YRDToString(name),
		@"value" : YRDToString(value),
		@"incr" : @(valueIncrement),
	} mutableCopy];
	
	for (NSString *parameterName in parameters) {
		NSString *queryParamName = [NSString stringWithFormat:@"param[%@]", parameterName];
		query[queryParamName] = parameters[parameterName];
	}
	
	for (NSString *parameterName in parameterIncrements) {
		NSString *queryParamName = [NSString stringWithFormat:@"mod[%@]", parameterName];
		query[queryParamName] = parameterIncrements[parameterName];
	}
	
	YRDTrackCounterRequest *request = [[self alloc] initWithPath:@"stats/trackCounter.php" queryParameters:query];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDTrackCounterResponse class]];
	return request;
}

@end
