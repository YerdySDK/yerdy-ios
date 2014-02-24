//
//  Yerdy.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "Yerdy.h"
#import "Yerdy_Private.h"
#import "YRDConstants.h"
#import "YRDDelayedBlock.h"
#import "YRDLog.h"
#import "YRDLaunchRequest.h"
#import "YRDLaunchResponse.h"
#import "YRDLaunchTracker.h"
#import "YRDMessage.h"
#import "YRDMessagesRequest.h"
#import "YRDMessagePresenter.h"
#import "YRDTimeTracker.h"
#import "YRDURLConnection.h"
#import "YRDConversionTracker.h"
#import "YRDInAppPurchase.h"
#import "YRDItemPurchase.h"
#import "YRDReward.h"
#import "YRDWebViewController.h"
#import "YRDAppActionParser.h"

static Yerdy *sharedInstance;

static const NSTimeInterval TokenTimeout = 5.0;


@interface Yerdy () <YRDLaunchTrackerDelegate, YRDMessagePresenterDelegate>
{
	NSString *_publisherKey;
	
	NSDate *_lastBackground;
	YRDDelayedBlock *_delayedLaunchCall;
	YRDLaunchTracker *_launchTracker;
	YRDTimeTracker *_timeTracker;
	
	NSMutableArray *_messages;
	NSString *_currentPlacement;
	YRDMessagePresenter *_messagePresenter;
	
	YRDConversionTracker *_conversionTracker;
}
@end


@implementation Yerdy

+ (instancetype)startWithPublisherKey:(NSString *)key
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		YRDInfo(@"Starting...");
		
		[YRDRequest setPublisherKey:key];
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
	_launchTracker.delegate = self;
	
	_timeTracker = [[YRDTimeTracker alloc] init];
	
	_conversionTracker = [[YRDConversionTracker alloc] init];
	
	[self reportLaunch:YES];
	
	return self;
}

#pragma mark - Launch handling

- (void)launchTrackerDetectedResumeLaunch:(YRDLaunchTracker *)launchTracker
{
	[self reportLaunch:NO];
}

- (void)reportLaunch:(BOOL)initialLaunch
{
	__weak Yerdy *weakSelf = self;
	
	void(^block)(void) = ^{
		((Yerdy *)weakSelf)->_delayedLaunchCall = nil;
		
		// TODO: Should we call messages.php if the launch call fails?
		//		 Should we call -yerdyConnected if one or both of the calls fails?
		//		 Should we call -yerdyConnected if this is a resume launch
		YRDLaunchRequest *launchRequest = [YRDLaunchRequest launchRequestWithToken:self.pushToken
																		  launches:_launchTracker.launchCount
																		   crashes:_launchTracker.crashCount
																		  playtime:_timeTracker.timePlayed];
		[YRDURLConnection sendRequest:launchRequest completionHandler:^(YRDLaunchResponse *response, NSError *error) {
			if (response.success) {
				weakSelf.ABTag = response.tag;
			} else {
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
	if (initialLaunch && !hasToken) {
		_delayedLaunchCall = [YRDDelayedBlock afterDelay:TokenTimeout runBlock:block];
	} else {
		block();
	}
}

#pragma mark - Persisted properties

- (void)setPersistentObject:(id)object forKey:(NSString *)key
{
	if (object) {
		[[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
	} else {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	}
}

- (id)persistentObjectForKey:(NSString *)key
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setPushToken:(NSData *)pushToken
{
	[self setPersistentObject:pushToken forKey:YRDPushTokenDefaultsKey];
	if (pushToken != nil) {
		[_delayedLaunchCall callNow];
	}
}

- (NSData *)pushToken
{
	return [self persistentObjectForKey:YRDPushTokenDefaultsKey];
}

- (void)setABTag:(NSString *)ABTag
{
	[self setPersistentObject:ABTag forKey:YRDABTagDefaultsKey];
}

- (NSString *)ABTag
{
	return [self persistentObjectForKey:YRDABTagDefaultsKey];
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
	
	_currentPlacement = placement;
	_messagePresenter.delegate = self;
	[_messagePresenter present];
	
	[_conversionTracker didShowMessage:message];
	[_messages removeObject:message];
	
	return YES;
}

#pragma mark - YerdyMessageDelegate

// The Yerdy class acts a proxy between YRDMessagePresenter & the messageDelegate
// set by the user

#pragma mark Display lifecycle

- (void)messagePresenterWillPresentMessage:(YRDMessage *)message
{
	if ([_messageDelegate respondsToSelector:@selector(yerdy:willPresentMessageForPlacement:)])
		[_messageDelegate yerdy:self willPresentMessageForPlacement:_currentPlacement];

}

- (void)messagePresenterDidPresentMessage:(YRDMessage *)message
{
	if ([_messageDelegate respondsToSelector:@selector(yerdy:didPresentMessageForPlacement:)])
		[_messageDelegate yerdy:self didPresentMessageForPlacement:_currentPlacement];
}

- (void)messagePresenterWillDismissMessage:(YRDMessage *)message withAction:(NSNumber *)action parameter:(id)actionParameter
{
	if ([_messageDelegate respondsToSelector:@selector(yerdy:didPresentMessageForPlacement:)])
		[_messageDelegate yerdy:self willDismissMessageForPlacement:_currentPlacement];
}

- (void)messagePresenterDidDismissMessage:(YRDMessage *)message withAction:(NSNumber *)action parameter:(id)actionParameter
{
	if ([_messageDelegate respondsToSelector:@selector(yerdy:didPresentMessageForPlacement:)])
		[_messageDelegate yerdy:self didDismissMessageForPlacement:_currentPlacement];
	
	if (action != nil) {
		YRDMessageActionType actionType = action.integerValue;
		if (actionType == YRDMessageActionTypeExternalBrowser) {
			[[UIApplication sharedApplication] openURL:actionParameter];
		} else if (actionType == YRDMessageActionTypeInternalBrowser) {
			YRDWebViewController *web = [[YRDWebViewController alloc] initWithWindow:_messagePresenter.window URL:actionParameter];
			[web present];
		} else if (actionType == YRDMessageActionTypeApp) {
			YRDAppActionParser *parser = actionParameter;
			if (parser.actionType == YRDAppActionTypeInAppPurchase) {
				[self handleInAppPurchase:parser.actionInfo];
			} else if (parser.actionType == YRDAppActionTypeItemPurchase) {
				[self handleItemPurchase:parser.actionInfo];
			} else if (parser.actionType == YRDAppActionTypeReward) {
				[self handleReward:parser.actionInfo];
			}
		}
	}
}

#pragma mark Purchases & rewards

// Verify the user has setup the messageDelegate properly for the essential delegate methods
- (BOOL)verifyMessageDelegateSetupFor:(SEL)selector context:(NSString *)msg
{
	if (_messageDelegate == nil) {
		YRDError(@"Failed handling %@: you haven't set [Yerdy sharedYerdy].messageDelegate", msg);
		return NO;
	} else if ([_messageDelegate respondsToSelector:selector] == NO) {
		YRDError(@"Failed handling %@: your YerdyMessageDelegate doesn't implement %@", msg, NSStringFromSelector(selector));
		return NO;
	} else {
		return YES;
	}
}

- (void)handleInAppPurchase:(YRDInAppPurchase *)purchase
{
	if (![self verifyMessageDelegateSetupFor:@selector(yerdy:handleInAppPurchase:) context:@"in app purchase"]) {
		return;
	}
	[_messageDelegate yerdy:self handleInAppPurchase:purchase];
}

- (void)handleItemPurchase:(YRDItemPurchase *)purchase
{
	if (![self verifyMessageDelegateSetupFor:@selector(yerdy:handleItemPurchase:) context:@"item purchase"]) {
		return;
	}
	[_messageDelegate yerdy:self handleItemPurchase:purchase];
}

- (void)handleReward:(YRDReward *)reward
{
	if (![self verifyMessageDelegateSetupFor:@selector(yerdy:handleReward:) context:@"reward"]) {
		return;
	}
	[_messageDelegate yerdy:self handleReward:reward];
}

@end
