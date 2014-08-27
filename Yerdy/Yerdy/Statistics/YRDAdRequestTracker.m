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

@interface YRDAdRequestTracker ()
{
	NSMutableArray *_preLaunchReportRequests;
	NSMutableArray *_preLaunchReportFills;
	
	BOOL _hasReportedLaunch;
}
@end


@implementation YRDAdRequestTracker

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_preLaunchReportRequests = [[NSMutableArray alloc] init];
	_preLaunchReportFills = [[NSMutableArray alloc] init];
	_hasReportedLaunch = NO;
	
	return self;
}

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
	
	if (_hasReportedLaunch) {
		NSMutableDictionary *currentRequests = [self.adRequests mutableCopy];
		
		NSInteger prevCount = [currentRequests[adNetworkName] integerValue];
		currentRequests[adNetworkName] = @(prevCount + 1);
		
		[[YRDDataStore sharedDataStore] setObject:currentRequests forKey:YRDAdRequestsDefaultsKey];
	} else {
		[_preLaunchReportRequests addObject:adNetworkName];
	}
}

- (void)logAdFill:(NSString *)adNetworkName
{
	adNetworkName = [YRDUtil sanitizeParamKey:adNetworkName context:@"Ad network name"];
	
	if (_hasReportedLaunch) {
		NSMutableDictionary *currentFills = [self.adFills mutableCopy];
		
		NSInteger prevCount = [currentFills[adNetworkName] integerValue];
		currentFills[adNetworkName] = @(prevCount + 1);
		
		[[YRDDataStore sharedDataStore] setObject:currentFills forKey:YRDAdFillsDefaultsKey];
	} else {
		[_preLaunchReportFills addObject:adNetworkName];
	}
}

- (void)launchReported
{
	if (!_hasReportedLaunch) {
		_hasReportedLaunch = YES;
		
		for (NSString *networkName in _preLaunchReportRequests)
			[self logAdRequest:networkName];
		[_preLaunchReportRequests removeAllObjects];
		
		for (NSString *networkName in _preLaunchReportFills)
			[self logAdFill:networkName];
		[_preLaunchReportFills removeAllObjects];
	}
}

- (void)reset
{
	[[YRDDataStore sharedDataStore] removeObjectForKey:YRDAdRequestsDefaultsKey];
	[[YRDDataStore sharedDataStore] removeObjectForKey:YRDAdFillsDefaultsKey];
}

@end
