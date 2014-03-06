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
#import "YRDImageCache.h"
#import "YRDItemPurchase.h"
#import "YRDReward.h"
#import "YRDWebViewController.h"
#import "YRDAppActionParser.h"
#import "YRDCurrencyTracker.h"
#import "YRDTrackPurchaseRequest.h"
#import "YRDTrackVirtualPurchaseRequest.h"
#import "YRDTrackPurchaseResponse.h"
#import "YRDPurchase_Private.h"
#import "YRDScreenVisitTracker.h"
#import "YRDUtil.h"
#import "YRDProgressionTracker.h"


static Yerdy *sharedInstance;

// The user provided key is split on this index to get the internal key & secret
//	key =		0..PublisherKeyPartLength
//	secret = 	PublisherKeyPartLength..(end of string)
static const NSUInteger PublisherKeyPartLength = 16;

static const NSTimeInterval TokenTimeout = 5.0;

static const NSUInteger MaxImagePreloads = 6;


@interface Yerdy () <YRDLaunchTrackerDelegate, YRDMessagePresenterDelegate>
{
	NSString *_publisherKey;
	
	NSDate *_lastBackground;
	YRDDelayedBlock *_delayedLaunchCall;
	YRDLaunchTracker *_launchTracker;
	YRDTimeTracker *_timeTracker;
	
	NSMutableArray *_messages;
	YRDMessagePresenter *_messagePresenter;
	BOOL _forceMessageFetchNextResume;
	BOOL _didDismissMessage;
	
	NSString *_currentPlacement;
	NSUInteger _messagesPresentedInRow;
	
	YRDConversionTracker *_conversionTracker;
	YRDCurrencyTracker *_currencyTracker;
	YRDScreenVisitTracker *_screenVisitTracker;
	
	YRDProgressionTracker *_progressionTracker;
}
@end


@implementation Yerdy

+ (instancetype)startWithPublisherKey:(NSString *)key
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		YRDInfo(@"Starting...");
		
		if (key.length < PublisherKeyPartLength) {
			[NSException raise:NSInvalidArgumentException format:@"Yerdy key '%@' not valid", key];
		}
		
		// Key portion is first 16 bytes
		NSString *publisherKey = [key substringToIndex:PublisherKeyPartLength];
		// Secret portion is last bytes
		NSString *publisherSecret = [key substringFromIndex:PublisherKeyPartLength];
		
		[YRDRequest setPublisherKey:publisherKey];
		[YRDRequest setPublisherSecret:publisherSecret];
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
	
	BOOL newVersion = [self checkVersion];
	
	_launchTracker = [[YRDLaunchTracker alloc] init];
	_launchTracker.delegate = self;
	if (newVersion)
		[_launchTracker reset];
	
	_timeTracker = [[YRDTimeTracker alloc] init];
	if (newVersion)
		[_timeTracker resetVersionTimePlayed];
	
	_conversionTracker = [[YRDConversionTracker alloc] init];
	_currencyTracker = [[YRDCurrencyTracker alloc] init];
	_screenVisitTracker = [[YRDScreenVisitTracker alloc] init];
	
	_progressionTracker = [[YRDProgressionTracker alloc] initWithCurrencyTracker:_currencyTracker];
	
	[self reportLaunch:YES];
	
	return self;
}

- (BOOL)checkVersion
{
	// Various stats are tracked per version, so we need to reset them
	// when we detect a new version of the application
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *lastKnownAppVersion = [defaults objectForKey:YRDAppVersionDefaultsKey];
	NSString *appVersion = [YRDUtil appVersion];
	
	if (![lastKnownAppVersion isEqualToString:appVersion]) {
		[defaults setObject:appVersion forKey:YRDAppVersionDefaultsKey];
		return YES;
	} else {
		return NO;
	}
}

#pragma mark - Launch handling

- (void)launchTracker:(YRDLaunchTracker *)launchTracker detectedResumeOfType:(YRDResumeType)resumeType
{
	if (resumeType == YRDLongResume)
		[self reportLaunch:NO];
	else if (resumeType == YRDShortResume && _forceMessageFetchNextResume)
		[self fetchMessages];
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
																		  playtime:_timeTracker.versionTimePlayed
																		  currency:_currencyTracker.currencyBalance
																	  screenVisits:_screenVisitTracker.loggedScreenVisits];
		// TODO: Only reset if we have internet
		[_screenVisitTracker reset];
		
		[YRDURLConnection sendRequest:launchRequest completionHandler:^(YRDLaunchResponse *response, NSError *error) {
			if (response.success) {
				weakSelf.ABTag = response.tag;
				weakSelf.userType = response.userType;
			} else {
				YRDError(@"Failed to report launch: %@", error);
			}
			
			[weakSelf fetchMessages];
		}];
	};
	
	BOOL hasToken = [self pushToken] != nil;
	if (initialLaunch && !hasToken) {
		_delayedLaunchCall = [YRDDelayedBlock afterDelay:TokenTimeout runBlock:block];
	} else if (initialLaunch) {
		// let them register currencies, etc...
		dispatch_async(dispatch_get_main_queue(), block);
	} else {
		block();
	}
}

- (void)fetchMessages
{
	_forceMessageFetchNextResume = NO;
	
	YRDMessagesRequest *messagesRequest = [YRDMessagesRequest messagesRequest];
	
	__weak Yerdy *weakSelf = self;
	[YRDURLConnection sendRequest:messagesRequest completionHandler:^(NSArray *response, NSError *error) {
		[weakSelf messagesReceived:response];
	}];
}

- (void)messagesReceived:(NSArray *)messages
{
	_messages = [messages mutableCopy];
	
	YRDImageCache *imageCache = [YRDImageCache sharedCache];
	
	__block BOOL finishedQueuingImages = NO;
	__block int imagesRemaining = 0;
	
	__weak id<YerdyDelegate> weakDelegate = _delegate;
	
	void(^finished)(void) = ^{
		[weakDelegate yerdyConnected];
	};
	
	void(^completionHandler)(id) = ^(id image) {
		if (--imagesRemaining == 0 && finishedQueuingImages)
			finished();
	};
	
	for (YRDMessage *message in _messages) {
		if (message.image != nil) {
			imagesRemaining++;
			[imageCache loadImageAtURL:message.image completionHandler:completionHandler];
		}
		
		if (message.watermarkImage != nil) {
			imagesRemaining++;
			[imageCache loadImageAtURL:message.watermarkImage completionHandler:completionHandler];
		}
		
		if (imageCache.numberOfActiveRequests > MaxImagePreloads)
			break;
	}
	
	finishedQueuingImages = YES;
	if (imagesRemaining == 0)
		finished();
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

- (void)setUserType:(YRDUserType)userType
{
	[self setPersistentObject:@(userType) forKey:YRDUserTypeDefaultsKey];
}

- (YRDUserType)userType
{
	return [[self persistentObjectForKey:YRDUserTypeDefaultsKey] intValue];
}

- (BOOL)isPremiumUser
{
	return self.userType == YRDUserTypePay;
}

- (int)itemsPurchased
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:YRDItemsPurchasedDefaultsKey];
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
	return [self internalShowMessage:placement inWindow:window first:YES];
}

- (BOOL)internalShowMessage:(NSString *)placement inWindow:(UIWindow *)window first:(BOOL)first
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
	
	if (first) {
		_messagesPresentedInRow = 1;
		_didDismissMessage = NO;
	} else {
		_messagesPresentedInRow++;
	}
	
	_currentPlacement = placement;
	_messagePresenter.delegate = self;
	[_messagePresenter present];
	
	[_conversionTracker didShowMessage:message];
	[_messages removeObject:message];
	
	return YES;
}

- (void)dismissMessage
{
	_didDismissMessage = YES;
	[_messagePresenter dismiss];
}

#pragma mark - YRDMessagePresenterDelegate

// The Yerdy class acts a proxy between YRDMessagePresenter & the messageDelegate
// set by the user

- (BOOL)shouldShowAnotherMessage
{
	return !_didDismissMessage && [self messageAvailable:_currentPlacement];
}

#pragma mark Display lifecycle

- (void)messagePresenter:(YRDMessagePresenter *)presenter willPresentMessage:(YRDMessage *)message
{
	if (_messagesPresentedInRow > 1)
		return;
	
	if ([_messageDelegate respondsToSelector:@selector(yerdy:willPresentMessageForPlacement:)])
		[_messageDelegate yerdy:self willPresentMessageForPlacement:_currentPlacement];

}

- (void)messagePresenter:(YRDMessagePresenter *)presenter didPresentMessage:(YRDMessage *)message
{
	if (_messagesPresentedInRow > 1)
		return;
	
	if ([_messageDelegate respondsToSelector:@selector(yerdy:didPresentMessageForPlacement:)])
		[_messageDelegate yerdy:self didPresentMessageForPlacement:_currentPlacement];
}

- (void)messagePresenter:(YRDMessagePresenter *)presenter willDismissMessage:(YRDMessage *)message withAction:(NSNumber *)action parameter:(id)actionParameter
{
	if (action == nil && [self shouldShowAnotherMessage]) {
		_messagePresenter = nil;
		if ([self internalShowMessage:_currentPlacement inWindow:presenter.window first:NO]) {
			return;
		} else {
			_messagePresenter = presenter;
		}
	}
	
	if ([_messageDelegate respondsToSelector:@selector(yerdy:didPresentMessageForPlacement:)])
		[_messageDelegate yerdy:self willDismissMessageForPlacement:_currentPlacement];
}

- (void)messagePresenter:(YRDMessagePresenter *)presenter didDismissMessage:(YRDMessage *)message withAction:(NSNumber *)action parameter:(id)actionParameter
{
	if (_messagePresenter != presenter)
		return;
	
	_messagePresenter = nil;
	
	if ([_messageDelegate respondsToSelector:@selector(yerdy:didPresentMessageForPlacement:)])
		[_messageDelegate yerdy:self didDismissMessageForPlacement:_currentPlacement];
	
	if (action != nil) {
		if (message.forceRefresh)
			_forceMessageFetchNextResume = YES;
		
		YRDMessageActionType actionType = action.integerValue;
		if (actionType == YRDMessageActionTypeExternalBrowser) {
			[[UIApplication sharedApplication] openURL:actionParameter];
		} else if (actionType == YRDMessageActionTypeInternalBrowser) {
			YRDWebViewController *web = [[YRDWebViewController alloc] initWithWindow:presenter.window URL:actionParameter];
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


#pragma mark - Currency analytics

- (void)registerCurrencies:(NSArray *)currencies
{
	[_currencyTracker registerCurrencies:currencies];
}

- (void)setInitialCurrencies:(NSDictionary *)initialCurrencies
{
	BOOL applied = [[self persistentObjectForKey:YRDAppliedInitialCurrencyDefaultsKey] boolValue];
	if (!applied) {
		[_currencyTracker earnedCurrencies:initialCurrencies];
		[self setPersistentObject:@YES forKey:YRDAppliedInitialCurrencyDefaultsKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)earnedCurrency:(NSString *)currency amount:(NSUInteger)amount
{
	[_currencyTracker earnedCurrency:currency amount:amount];
}

- (void)earnedCurrencies:(NSDictionary *)currencies
{
	[_currencyTracker earnedCurrencies:currencies];
}

- (void)purchasedItem:(NSString *)item withCurrency:(NSString *)currency amount:(NSUInteger)amount
{
	// TODO: arg validation
	[self purchasedItem:item withCurrencies:@{ currency: @(amount) }];
}

- (void)purchasedItem:(NSString *)item withCurrencies:(NSDictionary *)currencies
{
	// TODO: arg validation
	[self purchasedItem:item withCurrencies:currencies onSale:NO];
}

- (void)purchasedItem:(NSString *)item withCurrencies:(NSDictionary *)currencies onSale:(BOOL)onSale
{
	// TODO: arg validation
	
	// update items purchased count
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger itemsPurchased = [defaults integerForKey:YRDItemsPurchasedDefaultsKey];
	itemsPurchased += 1;
	[defaults setInteger:itemsPurchased forKey:YRDItemsPurchasedDefaultsKey];
	
	NSNumber *itemsPurchasedSinceInApp = [defaults objectForKey:YRDItemsPurchasedSinceInAppDefaultsKey];
	if (itemsPurchasedSinceInApp != nil) {
		itemsPurchasedSinceInApp = @([itemsPurchasedSinceInApp integerValue] + 1);
		[defaults setObject:itemsPurchasedSinceInApp forKey:YRDItemsPurchasedSinceInAppDefaultsKey];
	}
	
	// send track virtual purchase
	NSArray *currencyArray = [_currencyTracker currencyDictionaryToArray:currencies];
	YRDTrackVirtualPurchaseRequest *request = [YRDTrackVirtualPurchaseRequest requestWithItem:item
																						price:currencyArray
																					   onSale:onSale
																				firstPurchase:itemsPurchased == 1
																		  purchasesSinceInApp:itemsPurchasedSinceInApp];
	
	[YRDURLConnection sendRequest:request completionHandler:^(YRDTrackPurchaseResponse *response, NSError *error) {
		YRDDebug(@"trackVirtualPurchase result: %d", response.result);
	}];
	
	// update currencies
	[_currencyTracker spentCurrencies:currencies];
}

- (void)purchasedInApp:(YRDPurchase *)purchase
{
	[self purchasedInApp:purchase currencies:nil];
}

- (void)purchasedInApp:(YRDPurchase *)purchase currency:(NSString *)currency amount:(NSUInteger)amount
{
	// TODO: arg validation
	[self purchasedInApp:purchase currencies:@{ currency : @(amount) }];
}

- (void)purchasedInApp:(YRDPurchase *)purchase currencies:(NSDictionary *)currencies
{
	// TODO: arg validation
	NSArray *currencyArray = [_currencyTracker currencyDictionaryToArray:currencies];
	NSInteger itemsPurchased = [[NSUserDefaults standardUserDefaults] integerForKey:YRDItemsPurchasedDefaultsKey];
	
	[purchase completeObjectWithCompletionHandler:^(BOOL success) {
		YRDTrackPurchaseRequest *request = [YRDTrackPurchaseRequest requestWithPurchase:purchase
																			   currency:currencyArray
																			   launches:_launchTracker.launchCount
																			   playtime:_timeTracker.timePlayed
																		currencyBalance:_currencyTracker.currencyBalance
																		 earnedCurrency:_currencyTracker.currencyEarned
																		  spentCurrency:_currencyTracker.currencySpent
																	  purchasedCurrency:_currencyTracker.currencyPurchased
																		 itemsPurchased:itemsPurchased];
		[YRDURLConnection sendRequest:request completionHandler:^(YRDTrackPurchaseResponse *response, NSError *error) {
			BOOL retry = NO;
			
			if (error && [error.domain isEqualToString:YRDErrorDomain]) {
				if (error.code == 401 || error.code == 403) {
					YRDError(@"trackPurchase - likely invalid publisher key/secret (HTTP status code %d)", error.code);
				} else if (error.code == 402) {
					YRDError(@"trackPurchase - missing receipt/invalid purchase (HTTP status code %d)", error.code);
				} else if (error.code == 501) {
					YRDError(@"trackPurchase - invalid/unsupported API version (HTTP status code %d)", error.code);
				} else {
					YRDError(@"trackPurchase - retry, other status code: (HTTP status code %d)", error.code);
					retry = YES;
				}
			} else if (error) {
				YRDError(@"trackPurchase - retry, generic error: %@", error);
				retry = YES;
			} else if (response.result == YRDTrackPurchaseResultServerError) {
				YRDError(@"trackPurchase - retry, server error: %@", error);
				retry = YES;
			}
			
			if (response.result == YRDTrackPurchaseResultSuccess) {
				[[NSUserDefaults standardUserDefaults] setObject:@0 forKey:YRDItemsPurchasedSinceInAppDefaultsKey];
			}
			
			YRDDebug(@"trackPurchase result: %d", response.result);
		}];
	}];
	
	[_currencyTracker purchasedCurrencies:currencies];
}

#pragma mark - Screen Visit Tracking

- (void)logScreenVisit:(NSString *)screenName
{
	[_screenVisitTracker logScreenVisit:screenName];
}


@end
