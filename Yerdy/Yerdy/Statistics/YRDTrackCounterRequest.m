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
#import "Yerdy_Private.h"


@implementation YRDTrackCounterRequest

+ (instancetype)requestWithCounterName:(NSString *)name
								 value:(NSString *)value
							 increment:(int)valueIncrement
							parameters:(NSDictionary *)parameters
				   parameterIncrements:(NSDictionary *)parameterIncrements
{
	NSString *mainParamName = [NSString stringWithFormat:@"idx[%@]", name];
	NSString *mainModName = [NSString stringWithFormat:@"mod[%@]", name];
	
	NSMutableDictionary *query = [@{
		@"name" : YRDToString(name),
		@"tag" : YRDToString([Yerdy sharedYerdy].ABTag),
		@"api" : @3,
		
		// idx[<name>]=<value>
		mainParamName : value,
		// mod[<name>]=<value>
		mainModName : @(valueIncrement),
	} mutableCopy];
	
	for (NSString *parameterName in parameters) {
		NSString *queryParamName = [NSString stringWithFormat:@"idx[%@]", parameterName];
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
