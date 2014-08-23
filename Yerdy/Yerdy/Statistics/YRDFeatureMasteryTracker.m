//
//  YRDFeatureMasteryTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-08-23.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDFeatureMasteryTracker.h"
#import "YRDConstants.h"
#import "YRDCounterEvent.h"
#import "YRDDataStore.h"
#import "YRDLaunchTracker.h"
#import "YRDTimeTracker.h"
#import "YRDTrackCounterBatcher.h"

//TODO: Make this configurable
static NSInteger Thresholds[] = { 1, 4, 8 };
static NSInteger ThresholdCount = 3;


@interface YRDFeatureMasteryTracker ()
{
	YRDTrackCounterBatcher *_counterBatcher;
	YRDLaunchTracker *_launchTracker;
	YRDTimeTracker *_timeTracker;
}
@end

@implementation YRDFeatureMasteryTracker

- (id)initWithCounterBatcher:(YRDTrackCounterBatcher *)counterBatcher
			   launchTracker:(YRDLaunchTracker *)launchTracker
				 timeTracker:(YRDTimeTracker *)timeTracker
{
	self = [super init];
	if (!self)
		return nil;
	
	_counterBatcher = counterBatcher;
	_launchTracker = launchTracker;
	_timeTracker = timeTracker;
	
	return self;
}

- (void)logFeatureUse:(NSString *)featureName
{
	NSString *countsKey = [NSString stringWithFormat:YRDFeatureMasteryCountsFormat, featureName];
	NSInteger existingCount = [[YRDDataStore sharedDataStore] integerForKey:countsKey];
	[[YRDDataStore sharedDataStore] setInteger:existingCount + 1 forKey:countsKey];
	
	[self sendFeatureEventIfNeeded:featureName];
}

- (void)sendFeatureEventIfNeeded:(NSString *)featureName
{
	YRDDataStore *dataStore = [YRDDataStore sharedDataStore];
	
	NSString *countsKey = [NSString stringWithFormat:YRDFeatureMasteryCountsFormat, featureName];
	NSInteger count = [dataStore integerForKey:countsKey];
	
	NSString *submittedKey = [NSString stringWithFormat:YRDFeatureMasterySubmittedFormat, featureName];
	NSArray *submitted = [dataStore arrayForKey:submittedKey];
	if (submitted == nil) submitted = @[];
	
	NSMutableArray *mutableSubmitted = [submitted mutableCopy];
	
	for (int i = 0; i < ThresholdCount; i++) {
		int level = i + 1;
		
		if (count >= Thresholds[i] && ![submitted containsObject:@(level)]) {
			[self sendFeatureEvent:featureName level:level];
			[mutableSubmitted addObject:@(level)];
		}
	}
	
	[dataStore setObject:mutableSubmitted forKey:submittedKey];
}

- (void)sendFeatureEvent:(NSString *)featureName level:(int)level
{
	NSString *levelStr = [NSString stringWithFormat:@"_%d", level];
	
	YRDCounterEvent *event = [[YRDCounterEvent alloc] initWithType:YRDCounterTypeFeature name:featureName value:levelStr];
	[event setValue:levelStr increment:MAX(0, _launchTracker.totalLaunchCount) forParameter:@"launch_count"];
	[event setValue:levelStr increment:MAX(0, (NSUInteger)round(_timeTracker.timePlayed)) forParameter:@"playtime"];
	[_counterBatcher addEvent:event];
}

@end
