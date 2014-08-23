//
//  YRDTrackCounterRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackCounterRequest.h"
#import "YRDJSONResponseHandler.h"
#import "YRDLog.h"
#import "YRDTrackCounterResponse.h"
#import "YRDUtil.h"

#import "Yerdy_Private.h"


@implementation YRDTrackCounterRequest

+ (instancetype)requestWithCounterEvent:(YRDCounterEvent *)event
{
	NSAssert(event != nil, @"event must not be nil");
	
	return [self requestWithCounterEvents:@[ event ]];
}

+ (instancetype)requestWithCounterEvents:(NSArray *)events
{
	NSAssert(events.count > 0, @"must have at least 1 event");
	
	NSString *eventName = [events[0] name];
	YRDCounterType eventType = [(YRDCounterEvent *)events[0] type];
	
	NSMutableDictionary *query = [@{
		@"name" : YRDToString(eventName),
		@"tag" : YRDToString([Yerdy sharedYerdy].ABTag),
		@"api" : @3,
		@"type" : [self stringForCounterType:eventType],
	} mutableCopy];
	
	for (int i = 0; i < events.count; i++) {
		YRDCounterEvent *event = events[i];
		if ([event.name isEqualToString:eventName] == NO) {
			YRDError(@"Not all event names match! (got '%@', expected '%@')", event.name, eventName);
			continue;
		}
		
		if (event.type != eventType) {
			YRDError(@"Not all event types match! (got '%d - %@', expected '%d - %@')",
					 event.type, [self stringForCounterType:event.type],
					 eventType, [self stringForCounterType:eventType]);
			continue;
		}
		
		for (NSString *paramName in event.idx) {
			NSString *idxKey = [NSString stringWithFormat:@"idx[%@][%d]", paramName, i];
			NSString *modKey = [NSString stringWithFormat:@"mod[%@][%d]", paramName, i];
			
			NSNumber *mod = event.mod[paramName];
			if (!mod)
				mod = @1;
			
			query[idxKey] = event.idx[paramName];
			query[modKey] = mod;
		}
	}
	
	YRDTrackCounterRequest *request = [[self alloc] initWithPath:@"stats/trackCounter.php" queryParameters:query];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDTrackCounterResponse class]];
	return request;
}

+ (NSString *)stringForCounterType:(YRDCounterType)type
{
	switch (type) {
		case YRDCounterTypeCustom: return @"custom";
		case YRDCounterTypeTime: return @"time";
		case YRDCounterTypePlayer: return @"player";
		case YRDCounterTypeFeature: return @"feature";
	}
	
	YRDError(@"Unexpected counter type: %d, defaulting to 'custom'", type);
	return @"custom";
}

@end
