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
#import "YRDJSONResponseHandler.h"
#import "YRDLaunchResponse.h"
#import "YRDMessage.h"


static Yerdy *sharedInstance;


@interface Yerdy ()
{
	NSString *_publisherKey;
	
	YRDLaunchTracker *_launchTracker;
	NSMutableArray *_messages;
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
	__weak Yerdy *weakSelf = self;
	
	YRDRequest *request = [[YRDRequest alloc] initWithPath:@"/launch.php"];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDLaunchResponse class]];
	
	[[[YRDURLConnection alloc] initWithRequest:request completionHandler:^(id response, NSError *error) {
		YRDLaunchResponse *launchResponse = response;
		if (!launchResponse.success) {
			YRDError(@"Failed to report launch: %@", error);
			return;
		}
		
		YRDRequest *messagesRequest = [[YRDRequest alloc] initWithPath:@"/messages.php"];
		messagesRequest.responseHandler = [[YRDJSONResponseHandler alloc] initWithArrayOfObjectType:[YRDMessage class]];
		
		[[[YRDURLConnection alloc] initWithRequest:messagesRequest completionHandler:^(id response, NSError *error) {
			Yerdy *strongSelf = weakSelf;
			strongSelf->_messages = response;
			
			if ([_delegate respondsToSelector:@selector(yerdyConnected)])
				[_delegate yerdyConnected];
		}] send];
	}] send];
}

#pragma mark - Messaging

- (BOOL)messageAvailable:(NSString *)placement
{
	NSUInteger index = [_messages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return placement == nil || [((YRDMessage *)obj).placement isEqualToString:placement];
	}];
	
	return index != NSNotFound;
}

@end
