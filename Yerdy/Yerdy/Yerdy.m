//
//  Yerdy.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "Yerdy.h"
#import "YRDLaunchTracker.h"

@interface Yerdy ()
{
	YRDLaunchTracker *_launchTracker;
}
@end


@implementation Yerdy

+ (instancetype)sharedYerdy
{
	static Yerdy *sharedInstance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_launchTracker = [[YRDLaunchTracker alloc] init];
	
	return self;
}

@end
