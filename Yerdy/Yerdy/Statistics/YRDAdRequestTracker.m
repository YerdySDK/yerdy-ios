//
//  YRDAdRequestTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-05-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDAdRequestTracker.h"
#import "YRDConstants.h"
#import "YRDDataStore.h"
#import "YRDUtil.h"

@implementation YRDAdRequestTracker

- (NSDictionary *)adRequests
{
	NSDictionary *dictionary = [[YRDDataStore sharedDataStore] objectForKey:YRDAdRequestsDefaultsKey];
	if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
		dictionary = @{};
	}
	return dictionary;
}

- (NSDictionary *)adFills
{
	NSDictionary *dictionary = [[YRDDataStore sharedDataStore] objectForKey:YRDAdFillsDefaultsKey];
	if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
		dictionary = @{};
	}
	return dictionary;
}

- (void)logAdRequest:(NSString *)adNetworkName
{
	adNetworkName = [YRDUtil sanitizeParamKey:adNetworkName context:@"Ad network name"];
	
	NSMutableDictionary *currentRequests = [self.adRequests mutableCopy];
	
	NSInteger prevCount = [currentRequests[adNetworkName] integerValue];
	currentRequests[adNetworkName] = @(prevCount + 1);
	
	[[YRDDataStore sharedDataStore] setObject:currentRequests forKey:YRDAdRequestsDefaultsKey];
}

- (void)logAdFill:(NSString *)adNetworkName
{
	adNetworkName = [YRDUtil sanitizeParamKey:adNetworkName context:@"Ad network name"];
	
	NSMutableDictionary *currentFills = [self.adFills mutableCopy];
	
	NSInteger prevCount = [currentFills[adNetworkName] integerValue];
	currentFills[adNetworkName] = @(prevCount + 1);
	
	[[YRDDataStore sharedDataStore] setObject:currentFills forKey:YRDAdFillsDefaultsKey];
}

- (void)reset
{
	[[YRDDataStore sharedDataStore] removeObjectForKey:YRDAdRequestsDefaultsKey];
	[[YRDDataStore sharedDataStore] removeObjectForKey:YRDAdFillsDefaultsKey];
}

@end
