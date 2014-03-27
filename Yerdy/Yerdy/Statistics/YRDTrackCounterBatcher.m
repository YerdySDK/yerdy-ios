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
#import "YRDPaths.h"
#import "YRDReachability.h"
#import "YRDRequestCache.h"
#import "YRDTimeTracker.h"
#import "YRDTrackCounterRequest.h"
#import "YRDTrackCounterResponse.h"
#import "YRDURLConnection.h"

#import <UIKit/UIKit.h>

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

+ (NSString *)path
{
	return [[YRDPaths dataFilesDirectory] stringByAppendingPathComponent:@"batchedEvents.dat"];
}

+ (YRDTrackCounterBatcher *)loadFromDisk
{
	@try {
		YRDTrackCounterBatcher *fromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:[self path]];
		if (fromDisk)
			return fromDisk;
		else
			return [[YRDTrackCounterBatcher alloc] init];
	} @catch (...) {
		return [[YRDTrackCounterBatcher alloc] init];
	}
}

- (void)saveToDisk
{
	@try {
		[NSKeyedArchiver archiveRootObject:self toFile:[[self class] path]];
	} @catch (...) { }
}

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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveToDisk)
												 name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveToDisk)
												 name:UIApplicationWillTerminateNotification object:nil];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	// Call -[self init] so we get regular init stuff (like registering for notifcations)
	// and some sane default values (in case reading from aDecoder gives us nils)
	self = [self init];
	if (!self)
		return nil;
	
	NSDictionary *customEvents = [aDecoder decodeObjectForKey:@"customEvents"];
	if (customEvents) _customEvents = [customEvents mutableCopy];
	
	NSDictionary *timeEvents = [aDecoder decodeObjectForKey:@"timeEvents"];
	if (timeEvents) _timeEvents = [timeEvents mutableCopy];
	
	NSDictionary *playerEvents = [aDecoder decodeObjectForKey:@"playerEvents"];
	if (playerEvents) _playerEvents = [playerEvents mutableCopy];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if (_customEvents) [aCoder encodeObject:_customEvents forKey:@"customEvents"];
	if (_timeEvents) [aCoder encodeObject:_timeEvents forKey:@"timeEvents"];
	if (_playerEvents) [aCoder encodeObject:_playerEvents forKey:@"playerEvents"];
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
		
		if ([YRDReachability internetReachable]) {
			[YRDURLConnection sendRequest:request completionHandler:^(YRDTrackCounterResponse *response, NSError *error) {
				// do nothing for now...
			}];
		} else {
			[[YRDRequestCache sharedCache] storeRequest:request];
		}
	}
	
	[_customEvents removeAllObjects];
	[_timeEvents removeAllObjects];
	[_playerEvents removeAllObjects];
	
	[self saveToDisk];
}

@end
