//
//  YRDAppActionParser.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDAppActionParser.h"
#import "YRDInAppPurchase_Private.h"
#import "YRDItemPurchase_Private.h"
#import "YRDReward_Private.h"


@implementation YRDAppActionParser

- (id)initWithAppAction:(NSString *)appAction
{
	self = [super init];
	if (!self)
		return nil;
	
	if (![self parseAction:appAction])
		return nil;
	
	return self;
}

- (BOOL)parseAction:(NSString *)appAction
{
	// TODO: Finalize formats
	static NSString *iap = @"iap:";
	static NSString *item = @"item:";
	static NSString *reward = @"reward:";
	
	if ([appAction hasPrefix:iap]) {
		return [self parseInApp:[appAction substringFromIndex:iap.length]];
	} else if ([appAction hasPrefix:item]) {
		return [self parseItem:[appAction substringFromIndex:item.length]];
	} else if ([appAction hasPrefix:reward]) {
		return [self parseRewards:[appAction substringFromIndex:reward.length]];
	} else if ([appAction length] == 0) {
		_actionType = YRDAppActionTypeEmpty;
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)parseInApp:(NSString *)string
{
	// Simple product identifier for now (for example, "com.yerdy.YerdySample.GoldHelmet")
	_actionType = YRDAppActionTypeInAppPurchase;
	_actionInfo = [[YRDInAppPurchase alloc] initWithProductIdentifier:string];
	return YES;
}

- (BOOL)parseItem:(NSString *)string
{
	// Simply item name for now (for example, "goldHelmet")
	_actionType = YRDAppActionTypeItemPurchase;
	_actionInfo = [[YRDItemPurchase alloc] initWithItem:string];
	return YES;
}

- (BOOL)parseRewards:(NSString *)string
{
	// Example:  coins,5;lives,10;
	NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@",;"];
	NSArray *components = [string componentsSeparatedByCharactersInSet:charSet];
	
	// last item will be empty if 'string' ends in ';', so remove it
	if (components.lastObject != nil && [components.lastObject length] == 0) {
		NSMutableArray *arr = [components mutableCopy];
		[arr removeLastObject];
		components = arr;
	}
	
	// components should look similar to:
	// @[ @"coins", @"5", @"lives", @"10" ]
	
	// verify we have an even number
	if (components.count == 0 || components.count % 2 != 0) {
		return NO;
	}
	
	NSMutableDictionary *parsed = [NSMutableDictionary dictionary];
	for (int i = 0; i < components.count / 2; i++) {
		NSString *name = components[i * 2];
		NSString *amountString = components[i * 2 + 1];
		NSNumber *amount = @([amountString integerValue]);
		
		parsed[name] = amount;
	}
	
	_actionType = YRDAppActionTypeReward;
	_actionInfo = [[YRDReward alloc] initWithRewards:parsed];
	
	return YES;
}

@end
