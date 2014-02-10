//
//  Yerdy.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "Yerdy.h"
#import "YRDLog.h"
#import "YRDLaunchTracker.h"
#import "YRDRequest.h"
#import "YRDURLConnection.h"


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
		YRDInfo(@"Starting...");
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
	
	[self reportLaunch];
	
	return self;
}

- (void)reportLaunch
{
	YRDRequest *request = [[YRDRequest alloc] initWithPath:@"/launch.php"];
	[[[YRDURLConnection alloc] initWithRequest:request completionHandler:^(id response, NSError *error) {
		YRDError(@"%@", error);
	}] send];
}

@end
