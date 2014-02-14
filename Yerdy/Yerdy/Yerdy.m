//
//  Yerdy.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "Yerdy.h"
#import "YRDConstants.h"
#import "YRDDelayedBlock.h"
#import "YRDLog.h"
#import "YRDLaunchRequest.h"
#import "YRDLaunchResponse.h"
#import "YRDLaunchTracker.h"
#import "YRDMessage.h"
#import "YRDMessagesRequest.h"
#import "YRDMessagePresenter.h"
#import "YRDURLConnection.h"


static Yerdy *sharedInstance;

static const NSTimeInterval TokenTimeout = 5.0;


@interface Yerdy ()
{
	NSString *_publisherKey;
	
	YRDDelayedBlock *_delayedLaunchCall;
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
		YRDInfo(@"Starting...");
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
	
	[self reportLaunch:YES];
	
	return self;
}

- (void)reportLaunch:(BOOL)initialLaunch
{
	__weak Yerdy *weakSelf = self;
	
	void(^block)(void) = ^{
		((Yerdy *)weakSelf)->_delayedLaunchCall = nil;
		
		// TODO: Should we call messages.php if the launch call fails?
		//		 Should we call -yerdyConnected if one or both of the calls fails?
		//		 Should we call -yerdyConnected if this is a resume launch
		YRDLaunchRequest *launchRequest = [YRDLaunchRequest launchRequest];
		[YRDURLConnection sendRequest:launchRequest completionHandler:^(YRDLaunchResponse *response, NSError *error) {
			if (!response.success) {
				YRDError(@"Failed to report launch: %@", error);
			}
			
			YRDMessagesRequest *messagesRequest = [YRDMessagesRequest messagesRequest];
			[YRDURLConnection sendRequest:messagesRequest completionHandler:^(NSArray *response, NSError *error) {
				((Yerdy *)weakSelf)->_messages = [response mutableCopy];
				
				if (!error && [_delegate respondsToSelector:@selector(yerdyConnected)])
					[_delegate yerdyConnected];
			}];
		}];
	};
	
	BOOL hasToken = [self pushToken] != nil;
	if (!hasToken) {
		_delayedLaunchCall = [YRDDelayedBlock afterDelay:TokenTimeout runBlock:block];
	} else {
		block();
	}
}

#pragma mark - Push token

- (void)setPushToken:(NSData *)pushToken
{
	[[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:YRDPushTokenDefaultsKey];
	if (pushToken != nil) {
		[_delayedLaunchCall callNow];
	}
}

- (NSData *)pushToken
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:YRDPushTokenDefaultsKey];
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
	
	_messagePresenter = [YRDMessagePresenter presenterForMessage:message window:window];
	if (!_messagePresenter)
		return NO;
	
	[_messagePresenter present];
	
	return YES;
}

@end
