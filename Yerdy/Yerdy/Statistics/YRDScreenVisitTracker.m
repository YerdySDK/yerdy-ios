//
//  YRDScreenVisitTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-05.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDScreenVisitTracker.h"
#import "YRDConstants.h"
#import "YRDUtil.h"

@implementation YRDScreenVisitTracker

- (NSDictionary *)loggedScreenVisits
{
	NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:YRDScreenVisitsDefaultsKey];
	if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
		dictionary = @{};
	}
	return dictionary;
}

- (void)logScreenVisit:(NSString *)screenName
{
	screenName = [YRDUtil sanitizeParamKey:screenName context:@"Screen name"];
	
	NSMutableDictionary *currentVisits = [self.loggedScreenVisits mutableCopy];
	
	NSInteger prevCount = [currentVisits[screenName] integerValue];
	currentVisits[screenName] = @(prevCount + 1);
	
	[[NSUserDefaults standardUserDefaults] setObject:currentVisits forKey:YRDScreenVisitsDefaultsKey];
}

- (void)reset
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:YRDScreenVisitsDefaultsKey];
}

@end
