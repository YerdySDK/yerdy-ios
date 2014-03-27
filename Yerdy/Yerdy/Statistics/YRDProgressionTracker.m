//
//  YRDProgressionTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDProgressionTracker.h"
#import "Yerdy.h"
#import "Yerdy_Private.h"
#import "YRDConstants.h"
#import "YRDCurrencyTracker.h"
#import "YRDDataStore.h"
#import "YRDLaunchTracker.h"
#import "YRDLog.h"
#import "YRDReachability.h"
#import "YRDRequestCache.h"
#import "YRDTimeTracker.h"
#import "YRDTrackCounterBatcher.h"
#import "YRDTrackCounterRequest.h"
#import "YRDTrackCounterResponse.h"
#import "YRDURLConnection.h"



// Report an event on each of these intervals & then every 30 minutes
static int MinutesToReport[] = { 2, 4, 6, 8, 10, 15, 20, 25, 30, 40, 50, 60 };

@interface YRDProgressionTracker ()
{
	YRDCurrencyTracker *_currencyTracker;
	YRDTrackCounterBatcher *_counterBatcher;
	YRDLaunchTracker *_launchTracker;
	YRDTimeTracker *_timeTracker;
}
@end


@implementation YRDProgressionTracker

- (id)initWithCurrencyTracker:(YRDCurrencyTracker *)currencyTracker launchTracker:(YRDLaunchTracker *)launchTracker
				  timeTracker:(YRDTimeTracker *)timeTracker counterBatcher:(YRDTrackCounterBatcher *)batcher
{
	self = [super init];
	if (!self)
		return nil;
	
	_currencyTracker = currencyTracker;
	_launchTracker = launchTracker;
	_timeTracker = timeTracker;
	_counterBatcher = batcher;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minuteOfGameplayPassed:)
												 name:YRDTimeTrackerMinutePassedNotification object:nil];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldTrackEventsForUser
{
	Yerdy *yerdy = [Yerdy sharedYerdy];
	if (yerdy.isPreYerdyUser) {
		return yerdy.shouldTrackPreYerdyUsersProgression;
	} else {
		return YES;
	}
}

#pragma mark - Player progression events

- (void)logPlayerProgression:(NSString *)category milestone:(NSString *)milestone
{
	if (![self shouldTrackEventsForUser]) {
		YRDDebug(@"Ignoring milestone '%@' in '%@' for existing user", milestone, category);
		return;
	}
	
	YRDCounterEvent *event = [[YRDCounterEvent alloc] initWithType:YRDCounterTypePlayer name:category value:milestone];
	[event setValue:milestone increment:MAX(0, _launchTracker.totalLaunchCount) forParameter:@"launch_count"];
	[event setValue:milestone increment:MAX(0, (NSUInteger)round(_timeTracker.timePlayed)) forParameter:@"playtime"];
	[_counterBatcher addEvent:event];
}

#pragma mark - Time events

- (void)minuteOfGameplayPassed:(NSNotification *)notification
{
	int minute = [notification.userInfo[YRDTimeTrackerMinutesPassedKey] intValue];
	if ([self shouldReportOnMinute:minute]) {
		if (![self shouldTrackEventsForUser]) {
			YRDDebug(@"Ignoring time event at '%d minutes' for existing user", minute);
			return;
		}
		
		NSString *counterName = [NSString stringWithFormat:@"game-%d", minute];

		YRDCounterEvent *event = [[YRDCounterEvent alloc] initWithType:YRDCounterTypeTime
																  name:counterName
																 value:@"0"];
		
		// Add currency changes since last event
		NSDictionary *currencyDeltas = [self calculateCurrencyDeltasAndReset];
		for (NSString *paramName in currencyDeltas) {
			[event setValue:@"0"
				  increment:[currencyDeltas[paramName] unsignedIntegerValue]
			   forParameter:paramName];
		}
		
		NSNumber *vgp = [self calculateItemsDeltaBucketAndReset];
		[event setValue:[vgp description] forParameter:@"vgp"];
		

		YRDTrackCounterRequest *request = [YRDTrackCounterRequest requestWithCounterEvent:event];
		YRDInfo(@"Counter '%@' with item bucket: %@ and currency deltas since last: %@", counterName, vgp, currencyDeltas);
		
		if ([YRDReachability internetReachable]) {
			[YRDURLConnection sendRequest:request completionHandler:^(YRDTrackCounterResponse *response, NSError *error) {
				YRDInfo(@"trackCounter.php - %d", response.result);
			}];
		} else {
			[[YRDRequestCache sharedCache] storeRequest:request];
		}
	}
}

- (BOOL)shouldReportOnMinute:(int)minute
{
	if (minute <= 0)
		return NO;
	
	for (size_t i = 0; i < sizeof(MinutesToReport)/sizeof(int); i++) {
		if (minute == MinutesToReport[i])
			return YES;
	}
	
	if (minute % 30 == 0) {
		return YES;
	}
	
	return NO;
}

#pragma mark Currencies

// Builds a dictionary mapping parameters -> increment values (basically mod[]= in trackCounter.php)
// for game progression events (game-<minutes>)
- (NSDictionary *)calculateCurrencyDeltasAndReset
{
	YRDDataStore *dataStore = [YRDDataStore sharedDataStore];
	NSMutableDictionary *paramsToValues = [NSMutableDictionary dictionary];
	
	// earned-1 ... earned-6
	NSDictionary *earned = [self currencyChangeParamsWithPrefix:@"earned" currentAmount:_currencyTracker.currencyEarned
									  previousAmountDefaultsKey:YRDProgressionLastEarnedCurrencyDefaultsKey];
	[paramsToValues addEntriesFromDictionary:earned];
	[dataStore setObject:_currencyTracker.currencyEarned forKey:YRDProgressionLastEarnedCurrencyDefaultsKey];
	
	
	// purchased-1 ... purchased-6
	NSDictionary *purchased = [self currencyChangeParamsWithPrefix:@"purchased" currentAmount:_currencyTracker.currencyPurchased
										 previousAmountDefaultsKey:YRDProgressionLastPurchasedCurrencyDefaultsKey];
	[paramsToValues addEntriesFromDictionary:purchased];
	[dataStore setObject:_currencyTracker.currencyPurchased forKey:YRDProgressionLastPurchasedCurrencyDefaultsKey];
	
	
	// spent-1 ... spent-6
	NSDictionary *spent = [self currencyChangeParamsWithPrefix:@"spent" currentAmount:_currencyTracker.currencySpent
									 previousAmountDefaultsKey:YRDProgressionLastSpentCurrencyDefaultsKey];
	[paramsToValues addEntriesFromDictionary:spent];
	[dataStore setObject:_currencyTracker.currencySpent forKey:YRDProgressionLastSpentCurrencyDefaultsKey];
	
	return paramsToValues;
}

- (NSDictionary *)currencyChangeParamsWithPrefix:(NSString *)prefix currentAmount:(NSArray *)currentAmount
					   previousAmountDefaultsKey:(NSString *)previousAmountDefaultsKey
{
	NSArray *previous = [[YRDDataStore sharedDataStore] arrayForKey:previousAmountDefaultsKey];
	NSArray *increases = [self calculateCurrencyIncreasesFrom:previous to:currentAmount];
	
	NSMutableDictionary *paramsToValues = [NSMutableDictionary dictionary];
	for (int i = 0 ; i < increases.count; i++) {
		NSString *paramName = [NSString stringWithFormat:@"%@-%d", prefix, i + 1];
		
		if ([increases[i] intValue] > 0)
			paramsToValues[paramName] = increases[i];
	}
	return paramsToValues;
}

- (NSArray *)calculateCurrencyIncreasesFrom:(NSArray *)previous to:(NSArray *)current
{
	NSMutableArray *delta = [NSMutableArray arrayWithCapacity:current.count];
	
	for (int i = 0; i < current.count; i++) {
		NSUInteger currentValue = [current[i] unsignedIntegerValue];
		NSUInteger previousValue = 0;
		if (i < previous.count)
			previousValue = [previous[i] unsignedIntegerValue];
		
		[delta addObject:@(currentValue - previousValue)];
	}
	
	return delta;
}

#pragma mark Items purchased

- (NSNumber *)calculateItemsDeltaBucketAndReset
{
	YRDDataStore *dataStore = [YRDDataStore sharedDataStore];
	
	// vgp
	NSInteger currentItemsPurchased = [Yerdy sharedYerdy].itemsPurchased;
	NSInteger previousItemsPurchased = [dataStore integerForKey:YRDProgressionLastItemPurchasesDefaultsKey];
	[dataStore setInteger:currentItemsPurchased forKey:YRDProgressionLastItemPurchasesDefaultsKey];

	return [self bucketForItemsPurchasedDelta:currentItemsPurchased - previousItemsPurchased];
}

- (NSNumber *)bucketForItemsPurchasedDelta:(NSInteger)delta
{
	if (delta <= 0)			// 0
		return @0;
	else if (delta <= 5)	// 1-5
		return @1;
	else if (delta <= 10)	// 6-10
		return @2;
	else if (delta <= 20)	// 11-20
		return @3;
	else					// 20 +
		return @4;
}

@end

