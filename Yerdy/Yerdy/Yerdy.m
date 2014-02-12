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
#import "YRDMessagePresenter.h"


static Yerdy *sharedInstance;


@interface Yerdy ()
{
	NSString *_publisherKey;
	
	YRDLaunchTracker *_launchTracker;
	NSMutableArray *_messages;
	
	YRDMessagePresenter *_messagePresenter;
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

- (YRDMessage *)messageForPlacement:(NSString *)placement
{
	NSUInteger index = [_messages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return placement == nil || [((YRDMessage *)obj).placement isEqualToString:placement];
	}];
	
	if (index != NSNotFound)
		return _messages[index];
	else
		return nil;
}

- (BOOL)messageAvailable:(NSString *)placement
{
	return [self messageForPlacement:placement] != nil;
}

- (BOOL)showMessage:(NSString *)placement
{
	return [self showMessage:placement inWindow:nil];
}

- (BOOL)showMessage:(NSString *)placement inWindow:(UIWindow *)window
{
	if (window == nil) {
		window = [[UIApplication sharedApplication] keyWindow];
	}
	
	if (_messagePresenter)
		return NO;
	
	YRDMessage *message = [self messageForPlacement:placement];
	if (!message)
		return NO;
	
	_messagePresenter = [YRDMessagePresenter presenterForMessage:message];
	if (!_messagePresenter)
		return nil;
	
	[_messagePresenter presentInView:window];
	
	return YES;
}

@end
