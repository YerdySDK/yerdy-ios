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
#import "YRDHistoryTracker.h"
#import "YRDLaunchTracker.h"
#import "YRDLog.h"
#import "YRDTimeTracker.h"
#import "YRDTrackCounterBatcher.h"

static const NSInteger ThresholdCount = 3;


@interface YRDFeatureMasteryTracker ()
{
	YRDTrackCounterBatcher *_counterBatcher;
	YRDLaunchTracker *_launchTracker;
	YRDTimeTracker *_timeTracker;
	YRDHistoryTracker *_historyTracker;
	
	int _defaultThresholds[3];
	NSMutableDictionary *_featureThresholds;
}
@end

@implementation YRDFeatureMasteryTracker

- (id)initWithCounterBatcher:(YRDTrackCounterBatcher *)counterBatcher
			   launchTracker:(YRDLaunchTracker *)launchTracker
				 timeTracker:(YRDTimeTracker *)timeTracker
			  historyTracker:(YRDHistoryTracker *)historyTracker
{
	self = [super init];
	if (!self)
		return nil;
	
	_counterBatcher = counterBatcher;
	_launchTracker = launchTracker;
	_timeTracker = timeTracker;
	_historyTracker = historyTracker;
	
	_defaultThresholds[0] = 1;
	_defaultThresholds[1] = 4;
	_defaultThresholds[2] = 8;
	
	_featureThresholds = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void)logFeatureUse:(NSString *)featureName
{
	[_historyTracker addFeatureUse:featureName];
	
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
	
	
	int thresholds[3];
	if (_featureThresholds[featureName]) {
		NSValue *v = _featureThresholds[featureName];
		[v getValue:&thresholds];
	} else {
		for (int i = 0; i < ThresholdCount; i++)
			thresholds[i] = _defaultThresholds[i];
	}
	
	for (int i = 0; i < ThresholdCount; i++) {
		int level = i + 1;
		
		if (count >= thresholds[i] && ![submitted containsObject:@(level)]) {
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
	
	[_historyTracker addFeature:featureName level:level];
}

- (void)setFeatureUsesForNovice:(int)novice amateur:(int)amateur master:(int)master
{
	if (!(novice < amateur && amateur < master) || novice < 0 || amateur < 0 || master < 0) {
		YRDError(@"Invalid values for default feature uses.  (novice=%d, amateur=%d, master=%d)", novice, amateur, master);
		YRDError(@"All values must be positive and in ascending order (novice < amateur < master)");
		return;
	}
	
	_defaultThresholds[0] = novice;
	_defaultThresholds[1] = amateur;
	_defaultThresholds[2] = master;
}

- (void)setFeatureUsesForNovice:(int)novice amateur:(int)amateur master:(int)master forFeature:(NSString *)feature
{
	if (feature == nil) {
		YRDError(@"setFeatureUsesForNovice:amateur:master:forFeature - feature must not be nil");
		return;
	}
	
	if (!(novice < amateur && amateur < master) || novice < 0 || amateur < 0 || master < 0) {
		YRDError(@"Invalid values for feature '%@' uses.  (novice=%d, amateur=%d, master=%d)", feature, novice, amateur, master);
		YRDError(@"All values must be positive and in ascending order (novice < amateur < master)");
		return;
	}
	
	int thresholds[] = { novice, amateur, master };
	_featureThresholds[feature] = [[NSValue alloc] initWithBytes:&thresholds objCType:@encode(int[3])];
}

@end
