//
//  YRDReward.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDReward.h"

@implementation YRDReward

- (id)initWithRewards:(NSDictionary *)rewards
{
	self = [super init];
	if (!self)
		return nil;
	
	_rewards = rewards;
	
	return self;
}

@end
