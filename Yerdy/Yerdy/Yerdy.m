//
//  Yerdy.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "Yerdy.h"
#import "YRDLaunchTracker.h"


static Yerdy *sharedInstance;


@interface Yerdy ()
{
	NSString *_publisherKey;
	
	YRDLaunchTracker *_launchTracker;
}
@end


@implementation Yerdy

+ (instancetype)startWithPublisherKey:(NSString *)key
{	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] initWithPublisherKey:key];
	});
		
	return sharedInstance;
}

+ (instancetype)sharedYerdy
{
	return sharedInstance;
}

- (id)initWithPublisherKey:(NSString *)publisherKey
{
	self = [super init];
	if (!self)
		return nil;
	
	_publisherKey = publisherKey;
	_launchTracker = [[YRDLaunchTracker alloc] init];
	
	return self;
}

@end
