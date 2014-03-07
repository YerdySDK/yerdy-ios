//
//  YRDTrackCounterBatcher.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackCounterBatcher.h"
#import "YRDCounterEvent.h"
#import "YRDLog.h"

#import "YRDTimeTracker.h"
#import "YRDTrackCounterRequest.h"
#import "YRDTrackCounterResponse.h"

#import "YRDURLConnection.h"


// Upload every X minutes
static const int SEND_INTERVAL_MINUTES = 5;


@interface YRDTrackCounterBatcher ()
{
	// Maps event name -> array of YRDCounterEvents, separated by type (custom, time, player)
	NSMutableDictionary *_customEvents;
	NSMutableDictionary *_timeEvents;
	NSMutableDictionary *_playerEvents;
}
@end


@implementation YRDTrackCounterBatcher

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_customEvents = [NSMutableDictionary dictionary];
	_timeEvents = [NSMutableDictionary dictionary];
	_playerEvents = [NSMutableDictionary dictionary];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minutePassedNotification:)
												 name:YRDTimeTrackerMinutePassedNotification object:nil];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)minutePassedNotification:(NSNotification *)notification
{
	int minutes = [notification.userInfo[YRDTimeTrackerMinutesPassedKey] intValue];
	if (minutes % SEND_INTERVAL_MINUTES == 0) {
		[self flush];
	}
}

- (void)addEvent:(YRDCounterEvent *)event
{
	NSMutableDictionary *targetDictionary = nil;
	switch (event.type) {
		case YRDCounterTypeCustom: targetDictionary = _customEvents; break;
		case YRDCounterTypePlayer: targetDictionary = _playerEvents; break;
		case YRDCounterTypeTime: targetDictionary = _timeEvents; break;
	}
	
	if (!targetDictionary) {
		YRDError(@"Unable to find appropriate container for event of type '%d', discarding event '%@'", event.type, event.name);
		return;
	}
	
	NSMutableArray *events = targetDictionary[event.name];
	if (!events) {
		events = targetDictionary[event.name] = [NSMutableArray array];
	}
	
	// We *may* modify the event, make sure we don't touch the original (and that
	// modifications to the original don't screw us up later)
	event = [event copy];
	
	// fold parameters into any existing events (if the value of the parameter matches)
	// i.e.
	// Converts:
	//	event 1: idx[level]=level1, mod[level]=1
	//	event 2: idx[level]=level2, mod[level]=1
	//	new event: idx[level]=level1, mod[level]=1
	// To:
	//	event 1: idx[level]=level1, mod[level]=2  (event 1 mod[level] + new event mod[level] = 2)
	//	event 2: idx[level]=level2, mod[level]=1
	for (YRDCounterEvent *existing in events) {
		for (NSString *parameterName in event.parameterNames) {
			NSString *eventValue = [event valueForParameter:parameterName];
			NSString *existingValue = [existing valueForParameter:parameterName];
			
			if (existingValue && [eventValue isEqual:existingValue]) {
				// increment mod on existing event, remove it from the new event
				NSUInteger increment = [event incrementForParameter:parameterName];
				[existing incrementParameter:parameterName byAmount:increment];
				[event removeParameter:parameterName];
			}
		}
	}
	
	// We should only add this event if we *haven't* removed all parameters
	if (event.parameterNames.count > 0)
		[events addObject:event];
}

- (void)flush
{
	NSMutableArray *allEvents = [NSMutableArray array];
	[allEvents addObjectsFromArray:_customEvents.allValues];
	[allEvents addObjectsFromArray:_timeEvents.allValues];
	[allEvents addObjectsFromArray:_playerEvents.allValues];
	
	// eventGroup is an array of YRDCounterEvents with the same type & name
	for (NSArray *eventGroup in allEvents) {
		YRDTrackCounterRequest *request = [YRDTrackCounterRequest requestWithCounterEvents:eventGroup];
		YRDInfo(@"trackCounter - %@", request.queryParameters);
		[YRDURLConnection sendRequest:request completionHandler:^(YRDTrackCounterResponse *response, NSError *error) {
			// do nothing for now...
		}];
	}
	
	[_customEvents removeAllObjects];
	[_timeEvents removeAllObjects];
	[_playerEvents removeAllObjects];
}

@end
