//
//  YRDProgressionTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDProgressionTracker.h"
#import "YRDConstants.h"
#import "YRDCurrencyTracker.h"
#import "YRDTimeTracker.h"
#import "Yerdy_Private.h"
#import "YRDTrackCounterRequest.h"
#import "YRDTrackCounterResponse.h"
#import "YRDURLConnection.h"
#import "YRDLog.h"


// Report an event on each of these intervals & then every 30 minutes
static int MinutesToReport[] = { 2, 4, 6, 8, 10, 15, 20, 25, 30, 40, 50, 60 };

@interface YRDProgressionTracker ()
{
	YRDCurrencyTracker *_currencyTracker;
}
@end


@implementation YRDProgressionTracker

- (id)initWithCurrencyTracker:(YRDCurrencyTracker *)currencyTracker
{
	self = [super init];
	if (!self)
		return nil;
	
	_currencyTracker = currencyTracker;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minuteOfGameplayPassed:)
												 name:YRDTimeTrackerMinutePassedNotification object:nil];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)minuteOfGameplayPassed:(NSNotification *)notification
{
	int minute = [notification.userInfo[YRDTimeTrackerMinutesPassedKey] intValue];
	if ([self shouldReportOnMinute:minute]) {
		NSString *counterName = [NSString stringWithFormat:@"game-%d", minute];

		NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
		
		NSDictionary *currencyDeltas = [self calculateCurrencyDeltasAndReset];
		// add all param[]=0 for currencies
		for (NSString *paramName in currencyDeltas) {
			parameters[paramName] = @0;
		}
		
		NSNumber *vgp = [self calculateItemsDeltaBucketAndReset];
		parameters[@"vgp"] = vgp;
		
		YRDTrackCounterRequest *request = [YRDTrackCounterRequest requestWithCounterName:counterName value:@"0" increment:1
																			  parameters:parameters parameterIncrements:currencyDeltas];
		YRDInfo(@"Counter '%@' with item bucket: %@ and currency deltas since last: %@", counterName, vgp, currencyDeltas);
		
		[YRDURLConnection sendRequest:request completionHandler:^(YRDTrackCounterResponse *response, NSError *error) {
			YRDInfo(@"trackCounter.php - %d", response.result);
		}];
	}
}

#pragma mark - Currencies

// Builds a dictionary mapping parameters -> increment values (basically mod[]= in trackCounter.php)
// for game progression events (game-<minutes>)
- (NSDictionary *)calculateCurrencyDeltasAndReset
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *paramsToValues = [NSMutableDictionary dictionary];
	
	// earned-1 ... earned-6
	NSDictionary *earned = [self currencyChangeParamsWithPrefix:@"earned" currentAmount:_currencyTracker.currencyEarned
									  previousAmountDefaultsKey:YRDProgressionLastEarnedCurrencyDefaultsKey];
	[paramsToValues addEntriesFromDictionary:earned];
	[defaults setObject:_currencyTracker.currencyEarned forKey:YRDProgressionLastEarnedCurrencyDefaultsKey];
	
	
	// purchased-1 ... purchased-6
	NSDictionary *purchased = [self currencyChangeParamsWithPrefix:@"purchased" currentAmount:_currencyTracker.currencyPurchased
										 previousAmountDefaultsKey:YRDProgressionLastPurchasedCurrencyDefaultsKey];
	[paramsToValues addEntriesFromDictionary:purchased];
	[defaults setObject:_currencyTracker.currencyPurchased forKey:YRDProgressionLastPurchasedCurrencyDefaultsKey];
	
	
	// spent-1 ... spent-6
	NSDictionary *spent = [self currencyChangeParamsWithPrefix:@"spent" currentAmount:_currencyTracker.currencySpent
									 previousAmountDefaultsKey:YRDProgressionLastSpentCurrencyDefaultsKey];
	[paramsToValues addEntriesFromDictionary:spent];
	[defaults setObject:_currencyTracker.currencySpent forKey:YRDProgressionLastSpentCurrencyDefaultsKey];
	
	return paramsToValues;
}

- (NSDictionary *)currencyChangeParamsWithPrefix:(NSString *)prefix currentAmount:(NSArray *)currentAmount
					   previousAmountDefaultsKey:(NSString *)previousAmountDefaultsKey
{
	NSArray *previous = [[NSUserDefaults standardUserDefaults] arrayForKey:previousAmountDefaultsKey];
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

#pragma mark - Items purchased

- (NSNumber *)calculateItemsDeltaBucketAndReset
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// vgp
	int currentItemsPurchased = [Yerdy sharedYerdy].itemsPurchased;
	int previousItemsPurchased = [defaults integerForKey:YRDProgressionLastItemPurchasesDefaultsKey];
	[defaults setInteger:currentItemsPurchased forKey:YRDProgressionLastItemPurchasesDefaultsKey];

	return [self bucketForItemsPurchasedDelta:currentItemsPurchased - previousItemsPurchased];
}

- (NSNumber *)bucketForItemsPurchasedDelta:(int)delta
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

