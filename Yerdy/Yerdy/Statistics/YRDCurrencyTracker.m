//
//  YRDCurrencyTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-25.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDCurrencyTracker.h"
#import "YRDConstants.h"
#import "YRDDataStore.h"
#import "YRDLog.h"


static const NSUInteger MAX_CURRENCIES = 6;


@interface YRDCurrencyTracker ()
{
	NSString __strong *_currencies[MAX_CURRENCIES];
	
	NSInteger _earned[MAX_CURRENCIES];
	NSInteger _spent[MAX_CURRENCIES];
	NSInteger _purchased[MAX_CURRENCIES];
}
@end


@implementation YRDCurrencyTracker

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	[self readKey:YRDEarnedCurrencyDefaultsKey intoCArray:_earned];
	[self readKey:YRDSpentCurrencyDefaultsKey intoCArray:_spent];
	[self readKey:YRDPurchasedCurrencyDefaultsKey intoCArray:_purchased];
	
	return self;
}

#pragma mark - Currency setup

- (void)registerCurrencies:(NSArray *)currencies
{
	for (NSUInteger i = 0; i < MAX_CURRENCIES; i++)
		_currencies[i] = nil;
	
	for (int i = 0; i < currencies.count; i++) {
		if (i < 0 || i >= MAX_CURRENCIES) {
			YRDError(@"%@ outside range of possible currencies (0..%ld).  Ignoring.", currencies[i], (unsigned long)MAX_CURRENCIES);
			continue;
		}
		
		_currencies[i] = currencies[i];
	}
}

- (NSUInteger)indexForCurrency:(NSString *)string
{
	for (NSUInteger i = 0; i < MAX_CURRENCIES; i++)
		if ([string isEqualToString:_currencies[i]])
			return i;
	return NSNotFound;
}

- (NSArray *)currencyDictionaryToArray:(NSDictionary *)currencies
{
	NSInteger values[MAX_CURRENCIES] = { 0 };
	[self addCurrencies:currencies toCArray:values];
	
	id objectValues[MAX_CURRENCIES];
	for (int i = 0; i < MAX_CURRENCIES; i++)
		objectValues[i] = @(values[i]);
	
	return [NSArray arrayWithObjects:objectValues count:MAX_CURRENCIES];
}

#pragma mark - Type conversion

- (NSArray *)arrayFromCArray:(NSInteger[MAX_CURRENCIES])cArray
{
	id objects[MAX_CURRENCIES];
	for (NSUInteger i = 0; i < MAX_CURRENCIES; i++)
		objects[i] = @(cArray[i]);
	return [NSArray arrayWithObjects:objects count:MAX_CURRENCIES];
}

- (void)array:(NSArray *)array toCArray:(NSInteger[MAX_CURRENCIES])cArray
{
	NSUInteger count = MAX(array.count, MAX_CURRENCIES);
	for (NSUInteger i = 0; i < count; i++)
		cArray[i] = [array[i] integerValue];
}

#pragma mark - Persistence

- (void)readKey:(NSString *)key intoCArray:(NSInteger[MAX_CURRENCIES])cArray
{
	NSArray *array = [[YRDDataStore sharedDataStore] arrayForKey:key];
	[self array:array toCArray:cArray];
}

- (void)saveCArray:(NSInteger[MAX_CURRENCIES])cArray toKey:(NSString *)key
{
	NSArray *array = [self arrayFromCArray:cArray];
	[[YRDDataStore sharedDataStore] setObject:array forKey:key];
}

#pragma mark - Reading currency amounts

- (NSArray *)currencyBalance
{
	NSInteger computed[MAX_CURRENCIES];
	
	for (NSUInteger i = 0; i < MAX_CURRENCIES; i++)
		computed[i] = _earned[i] + _purchased[i] - _spent[i];
	
	return [self arrayFromCArray:computed];
}

- (NSArray *)currencyEarned
{
	return [self arrayFromCArray:_earned];
}

- (NSArray *)currencySpent
{
	return [self arrayFromCArray:_spent];
}

- (NSArray *)currencyPurchased
{
	return [self arrayFromCArray:_purchased];
}

#pragma mark - Updating currency

- (void)addCurrencies:(NSDictionary *)currencies toCArray:(NSInteger[MAX_CURRENCIES])cArray
{
	for (NSString *currencyName in currencies) {
		NSInteger value = [currencies[currencyName] integerValue];
		
		NSUInteger index = [self indexForCurrency:currencyName];
		if (index == NSNotFound) {
			YRDError(@"Currency named '%@' not registered. Ignoring!", currencyName);
			continue;
		}
		
		cArray[index] += value;
	}
}

- (NSDictionary *)validateAndClampCurrencies:(NSDictionary *)currencies debugContext:(NSString *)debugContext
{
	BOOL needsClamping = NO;
	for (NSString *key in currencies) {
		if ([currencies[key] integerValue] < 0) {
			needsClamping = YES;
			YRDError(@"Invalid %@ value for currency '%@': %@.  Please ensure only positive values are reported!",
					 debugContext, key, currencies[key]);
		}
	}
	
	if (needsClamping) {
		NSMutableDictionary *clampedResults = [currencies mutableCopy];
		for (NSString *key in currencies) {
			if ([currencies[key] integerValue] < 0) {
				clampedResults[key] = @0;
			}
		}
		return clampedResults;
	} else {
		return currencies;
	}
}

- (void)earnedCurrencies:(NSDictionary *)currencies
{
	currencies = [self validateAndClampCurrencies:currencies debugContext:@"earned"];
	
	[self addCurrencies:currencies toCArray:_earned];
	[self saveCArray:_earned toKey:YRDEarnedCurrencyDefaultsKey];
	
	[self debugLogCurrencies:currencies description:@"Earned"];
	[self debugLogBalance];
}

- (void)spentCurrencies:(NSDictionary *)currencies
{
	currencies = [self validateAndClampCurrencies:currencies debugContext:@"spent"];
	
	[self addCurrencies:currencies toCArray:_spent];
	[self saveCArray:_spent toKey:YRDSpentCurrencyDefaultsKey];
	
	[self debugLogCurrencies:currencies description:@"Spent"];
	[self debugLogBalance];
}

- (void)purchasedCurrencies:(NSDictionary *)currencies
{
	currencies = [self validateAndClampCurrencies:currencies debugContext:@"purchased"];
	
	[self addCurrencies:currencies toCArray:_purchased];
	[self saveCArray:_purchased toKey:YRDPurchasedCurrencyDefaultsKey];
	
	[self debugLogCurrencies:currencies description:@"Purchased"];
	[self debugLogBalance];
}

#pragma mark - Debugging

- (void)debugLogCurrencies:(NSDictionary *)currencies description:(NSString *)description
{
	if (YRDGetLogLevel() < YRDLogDebug)
		return; // to minimize performance hit when not using YRDLogDebug
	
	NSArray *currencyArray = [self currencyDictionaryToArray:currencies];
	YRDDebug(@"%@: %@", description, [currencyArray componentsJoinedByString:@", "]);
}

- (void)debugLogBalance
{
	if (YRDGetLogLevel() < YRDLogDebug)
		return; // to minimize performance hit when not using YRDLogDebug
	
	YRDDebug(@"Balance: %@", [self.currencyBalance componentsJoinedByString:@", "]);

}

@end
