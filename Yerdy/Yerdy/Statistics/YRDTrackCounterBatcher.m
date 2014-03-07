//
//  YRDTrackCounterBatcher.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackCounterBatcher.h"
#import "YRDCounterEvent.h"

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
	
	return self;
}

- (void)addEvent:(YRDCounterEvent *)event
{
	NSMutableArray *events = _customEvents[event.name];
	if (!events) {
		events = _customEvents[event.name] = [NSMutableArray array];
	}
	[events addObject:event];
}

@end
