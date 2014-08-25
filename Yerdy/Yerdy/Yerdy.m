//
//  Yerdy.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDCompilerChecks.h"

#import "Yerdy.h"
#import "Yerdy_Private.h"
#import "YRDAdRequestTracker.h"
#import "YRDAppActionParser.h"
#import "YRDBuildInfo.h"
#import "YRDConstants.h"
#import "YRDConversionTracker.h"
#import "YRDCounterEvent.h"
#import "YRDCurrencyTracker.h"
#import "YRDDataStore.h"
#import "YRDDelayedBlock.h"
#import "YRDFeatureMasteryTracker.h"
#import "YRDHistoryTracker.h"
#import "YRDImageCache.h"
#import "YRDInAppPurchase.h"
#import "YRDItemPurchase.h"
#import "YRDLaunchRequest.h"
#import "YRDLaunchResponse.h"
#import "YRDLaunchTracker.h"
#import "YRDLog.h"
#import "YRDMessage.h"
#import "YRDMessagePresenter.h"
#import "YRDMessagesRequest.h"
#import "YRDProgressionTracker.h"
#import "YRDPurchaseSubmitter.h"
#import "YRDPurchase_Private.h"
#import "YRDReachability.h"
#import "YRDRequestCache.h"
#import "YRDReward.h"
#import "YRDScreenVisitTracker.h"
#import "YRDTimeTracker.h"
#import "YRDTrackCounterBatcher.h"
#import "YRDTrackPurchaseRequest.h"
#import "YRDURLConnection.h"
#import "YRDUtil.h"
#import "YRDVirtualPurchase.h"
#import "YRDWebViewController.h"


#define VALIDATE_ARG_NON_NIL(context, arg)									\
	if (arg == nil) { YRDError(@"Error %@: %s was nil", context, #arg); return; }


static Yerdy *sharedInstance;

// The user provided key is split on this index to get the internal key & secret
//	key =		0..PublisherKeyPartLength
//	secret = 	PublisherKeyPartLength..(end of string)
static const NSUInteger PublisherKeyPartLength = 16;

static const NSTimeInterval TokenTimeout = 5.0;

static const NSUInteger MaxImagePreloads = 6;


@interface Yerdy () <YRDLaunchTrackerDelegate, YRDMessagePresenterDelegate, YRDWebViewControllerDelegate>
{
	NSString *_publisherKey;
	
	NSDate *_lastBackground;
	BOOL _sentLaunchCall;
	YRDDelayedBlock *_delayedLaunchCall;
	YRDLaunchTracker *_launchTracker;
	YRDTimeTracker *_timeTracker;
	
	YRDHistoryTracker *_historyTracker;
	
	NSMutableArray *_messages;
	YRDMessagePresenter *_messagePresenter;
	BOOL _forceMessageFetchNextResume;
	BOOL _didDismissMessage;
	YRDWebViewController *_currentWebViewController;
	
	NSString *_currentPlacement;
	NSUInteger _messagesPresentedInRow;
		
	YRDConversionTracker *_conversionTracker;
	YRDCurrencyTracker *_currencyTracker;
	YRDScreenVisitTracker *_screenVisitTracker;
	
	YRDProgressionTracker *_progressionTracker;
	YRDFeatureMasteryTracker *_featureMasteryTracker;
	
	YRDTrackCounterBatcher *_trackCounterBatcher;
	
	YRDPurchaseSubmitter *_purchaseSubmitter;
	
	YRDAdRequestTracker *_adRequestTracker;
}
@end


@implementation Yerdy

+ (instancetype)startWithPublisherKey:(NSString *)key
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		YRDInfo(@"Starting.  Version: %@", YRDBuildInfoVersion);
		
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
		
		YRDInfo(@"To enable test mode for this device, copy/paste the test ID below into the Yerdy dashboard.");
		NSString *testId = [YRDUtil testIdentifier] != nil ? [YRDUtil testIdentifier] : [YRDUtil deviceIdentifier];
		YRDInfo(@"Test Device ID: %@", testId);
	});
	
	return sharedInstance;
}

+ (instancetype)sharedYerdy
{
	return sharedInstance;
}

+ (void)setLogLevel:(YRDLogLevel)logLevel
{
	YRDSetLogLevel(logLevel);
}

- (id)initWithPublisherKey:(NSString *)publisherKey
{
	self = [super init];
	if (!self)
		return nil;
	
	_publisherKey = publisherKey;
	
	BOOL newVersion = [self checkVersion];
	if (newVersion)
		YRDDebug(@"Detected new version!");
	
	_launchTracker = [[YRDLaunchTracker alloc] init];
	_launchTracker.delegate = self;
	if (newVersion)
		[_launchTracker reset];
	
	_timeTracker = [[YRDTimeTracker alloc] init];
	if (newVersion)
		[_timeTracker resetVersionTimePlayed];
	
	_historyTracker = [[YRDHistoryTracker alloc] init];
	
	_conversionTracker = [[YRDConversionTracker alloc] init];
	_currencyTracker = [[YRDCurrencyTracker alloc] init];
	_screenVisitTracker = [[YRDScreenVisitTracker alloc] initWithHistoryTracker:_historyTracker];
	
	_trackCounterBatcher = [YRDTrackCounterBatcher loadFromDisk];

	_progressionTracker = [[YRDProgressionTracker alloc] initWithCurrencyTracker:_currencyTracker
																   launchTracker:_launchTracker
																	 timeTracker:_timeTracker
																  counterBatcher:_trackCounterBatcher
																  historyTracker:_historyTracker];
	
	_featureMasteryTracker = [[YRDFeatureMasteryTracker alloc] initWithCounterBatcher:_trackCounterBatcher
																		launchTracker:_launchTracker
																		  timeTracker:_timeTracker
																	   historyTracker:_historyTracker];
	
	
	_purchaseSubmitter = [YRDPurchaseSubmitter loadFromDisk];
	
	_adRequestTracker = [[YRDAdRequestTracker alloc] init];
	if (newVersion)
		[_adRequestTracker reset]; // reset on new versions, since this is mainly for tracking ad health, per version
	
	[self reportLaunch:YES];
	
	return self;
}

- (BOOL)checkVersion
{
	// Various stats are tracked per version, so we need to reset them
	// when we detect a new version of the application
	YRDDataStore *dataStore = [YRDDataStore sharedDataStore];
	NSString *lastKnownAppVersion = [dataStore objectForKey:YRDAppVersionDefaultsKey];
	NSString *appVersion = [YRDUtil appVersion];
	
	if (![lastKnownAppVersion isEqualToString:appVersion]) {
		[dataStore setObject:appVersion forKey:YRDAppVersionDefaultsKey];
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

- (void)reportLaunch:(BOOL)fullLaunch
{
	__weak Yerdy *weakSelf = self;
	
	void(^block)(void) = ^{
		((Yerdy *)weakSelf)->_sentLaunchCall = YES;
		((Yerdy *)weakSelf)->_delayedLaunchCall = nil;
		
		YRDLaunchRequest *launchRequest = [YRDLaunchRequest launchRequestWithToken:self.pushToken
																		  launches:_launchTracker.versionLaunchCount
																		   crashes:_launchTracker.versionCrashCount
																		  playtime:_timeTracker.versionTimePlayed
																		  currency:_currencyTracker.currencyBalance
																	  screenVisits:_screenVisitTracker.loggedScreenVisits
																		adRequests:_adRequestTracker.adRequests
																		   adFills:_adRequestTracker.adFills];
		
		if ([YRDReachability internetReachable]) {
			[_screenVisitTracker reset];
			[_adRequestTracker reset];
		}
		
		[YRDURLConnection sendRequest:launchRequest completionHandler:^(YRDLaunchResponse *response, NSError *error) {
			Yerdy *strongSelf = weakSelf;
			if (response.success) {
				strongSelf.ABTag = response.tag;
				strongSelf.userType = response.userType;
				
				if ([YRDReachability internetReachable])
					[[YRDRequestCache sharedCache] sendStoredRequests];
				[strongSelf->_purchaseSubmitter uploadIfNeeded];
			} else {
				if (error != nil)
					YRDError(@"Failed to report launch: %@", error);
				else
					YRDError(@"Failed to report launch, you may need to approve this app in the Yerdy dashboard.");
			}
			
			[strongSelf fetchMessages];
		}];
	};
	
	BOOL isFirstLaunch = ![[YRDDataStore sharedDataStore] boolForKey:YRDInitialLaunchCompletedDefaultsKey];
	if (isFirstLaunch) {
		[[YRDDataStore sharedDataStore] setBool:YES forKey:YRDInitialLaunchCompletedDefaultsKey];
	}
	
	if (fullLaunch && isFirstLaunch) {
		_delayedLaunchCall = [YRDDelayedBlock afterDelay:TokenTimeout runBlock:block];
	} else if (fullLaunch) {
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
	_messages = [[self filterMessages:messages] mutableCopy];
	
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

- (NSArray *)filterMessages:(NSArray *)messages
{
	NSIndexSet *indexes = [messages indexesOfObjectsPassingTest:^BOOL(YRDMessage *obj, NSUInteger idx, BOOL *stop) {
		if (obj.actionType == YRDMessageActionTypeApp) {
			YRDAppActionParser *parser = [[YRDAppActionParser alloc] initWithAppAction:obj.action];
			return parser != nil;
		} else {
			return YES;
		}
	}];
	return [messages objectsAtIndexes:indexes];
}

#pragma mark - Persisted properties

- (void)setPersistentObject:(id)object forKey:(NSString *)key
{
	if (object) {
		[[YRDDataStore sharedDataStore] setObject:object forKey:key];
	} else {
		[[YRDDataStore sharedDataStore] removeObjectForKey:key];
	}
}

- (id)persistentObjectForKey:(NSString *)key
{
	return [[YRDDataStore sharedDataStore] objectForKey:key];
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

- (NSInteger)itemsPurchased
{
	return [[YRDDataStore sharedDataStore] integerForKey:YRDItemsPurchasedDefaultsKey];
}

#pragma mark - Messaging

- (YRDMessage *)messageForPlacement:(NSString *)placement
{
	NSUInteger index = [_messages indexOfObjectPassingTest:^BOOL(YRDMessage *msg, NSUInteger idx, BOOL *stop) {
		return placement == nil || [msg.placement isEqualToString:@"*"] || [msg.placement isEqualToString:placement];
	}];
	
	if (index != NSNotFound)
		return _messages[index];
	else
		return nil;
}

- (BOOL)isMessageAvailable:(NSString *)placement
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
	
	if (_messagePresenter || _currentWebViewController)
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
	[_historyTracker addMessage:message.messageId];
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
	BOOL canShow = (!_didDismissMessage && [self isMessageAvailable:_currentPlacement]);
	
	if (canShow && [_messageDelegate respondsToSelector:@selector(yerdy:shouldShowAnotherMessageAfterUserCancelForPlacement:)]) {
		canShow = [_messageDelegate yerdy:self shouldShowAnotherMessageAfterUserCancelForPlacement:_currentPlacement];
	} else {
		canShow = NO; // if delegate method not implemented, default to NO
	}
	
	return canShow;
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
	
	// we don't send the "will dismiss" delegate method when the action is an internal browser,
	// as we'll be sending them later on when the browser is dismissed
	if ([_messageDelegate respondsToSelector:@selector(yerdy:willDismissMessageForPlacement:)] && (action.intValue != YRDMessageActionTypeInternalBrowser))
		[_messageDelegate yerdy:self willDismissMessageForPlacement:_currentPlacement];
}

- (void)messagePresenter:(YRDMessagePresenter *)presenter didDismissMessage:(YRDMessage *)message withAction:(NSNumber *)action parameter:(id)actionParameter
{
	if (_messagePresenter != presenter)
		return;
	
	_messagePresenter = nil;
	
	// we don't send the "will dismiss" delegate method when the action is an internal browser,
	// as we'll be sending them later on when the browser is dismissed
	if ([_messageDelegate respondsToSelector:@selector(yerdy:didDismissMessageForPlacement:)]
		&& action.integerValue != YRDMessageActionTypeInternalBrowser)
		[_messageDelegate yerdy:self didDismissMessageForPlacement:_currentPlacement];
	
	if (action != nil) {
		if (message.forceRefresh)
			_forceMessageFetchNextResume = YES;
		
		YRDMessageActionType actionType = action.intValue;
		if (actionType == YRDMessageActionTypeExternalBrowser) {
			[[UIApplication sharedApplication] openURL:actionParameter];
		} else if (actionType == YRDMessageActionTypeInternalBrowser) {
			_currentWebViewController = [[YRDWebViewController alloc] initWithWindow:presenter.window URL:actionParameter];
			_currentWebViewController.delegate = self;
			[_currentWebViewController present];
		} else if (actionType == YRDMessageActionTypeApp) {
			YRDAppActionParser *parser = actionParameter;
			if (parser.actionType == YRDAppActionTypeInAppPurchase) {
				[self handleInAppPurchase:parser.actionInfo];
			} else if (parser.actionType == YRDAppActionTypeItemPurchase) {
				[self handleItemPurchase:parser.actionInfo];
			} else if (parser.actionType == YRDAppActionTypeReward) {
				[self handleReward:parser.actionInfo];
			} else if (parser.actionType == YRDAppActionTypeNavigation) {
				[self handleNavigation:parser.actionInfo];
			}
		}
	}
}

- (void)webViewControllerWillDismiss:(YRDWebViewController *)webViewController
{
	if (webViewController != _currentWebViewController)
		return;
	
	if ([_messageDelegate respondsToSelector:@selector(yerdy:willDismissMessageForPlacement:)])
		[_messageDelegate yerdy:self willDismissMessageForPlacement:_currentPlacement];
}

- (void)webViewControllerDidDismiss:(YRDWebViewController *)webViewController
{
	if (webViewController != _currentWebViewController)
		return;
	_currentWebViewController = nil;
	
	if ([_messageDelegate respondsToSelector:@selector(yerdy:didDismissMessageForPlacement:)])
		[_messageDelegate yerdy:self didDismissMessageForPlacement:_currentPlacement];
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

- (void)handleNavigation:(NSString *)screenName
{
	if (![self verifyMessageDelegateSetupFor:@selector(yerdy:handleNavigation:) context:@"navigation"]) {
		return;
	}
	[_messageDelegate yerdy:self handleNavigation:screenName];
}

#pragma mark - Currency analytics

- (void)configureCurrencies:(NSArray *)currencies
{
	VALIDATE_ARG_NON_NIL(@"registering currencies", currencies);
	
	[_currencyTracker registerCurrencies:currencies];
}

- (void)earnedCurrency:(NSString *)currency amount:(NSInteger)amount
{
	VALIDATE_ARG_NON_NIL(@"reporting earned currency", currency);
	
	[self earnedCurrencies:@{ currency : @(amount) }];
}

- (void)earnedCurrencies:(NSDictionary *)currencies
{
	VALIDATE_ARG_NON_NIL(@"reporting earned currency", currencies);
	
	[_currencyTracker earnedCurrencies:currencies];
}

- (void)purchasedItem:(NSString *)item withCurrency:(NSString *)currency amount:(NSInteger)amount
{
	VALIDATE_ARG_NON_NIL(@"reporting item purchase", item);
	VALIDATE_ARG_NON_NIL(@"reporting item purchase", currency);
	
	[self purchasedItem:item withCurrencies:@{ currency: @(amount) }];
}

- (void)purchasedItem:(NSString *)item withCurrencies:(NSDictionary *)currencies
{
	VALIDATE_ARG_NON_NIL(@"reporting item purchase", item);
	VALIDATE_ARG_NON_NIL(@"reporting item purchase", currencies);
	
	[self purchasedItem:item withCurrencies:currencies onSale:NO];
}

- (void)purchasedItem:(NSString *)item withCurrencies:(NSDictionary *)currencies onSale:(BOOL)onSale
{
	VALIDATE_ARG_NON_NIL(@"reporting item purchase", item);
	VALIDATE_ARG_NON_NIL(@"reporting item purchase", currencies);
	
	[_historyTracker addItemPurchase:item];
	
	// update items purchased count
	YRDDataStore *defaults = [YRDDataStore sharedDataStore];
	NSInteger itemsPurchased = [defaults integerForKey:YRDItemsPurchasedDefaultsKey];
	itemsPurchased += 1;
	[defaults setInteger:itemsPurchased forKey:YRDItemsPurchasedDefaultsKey];
	
	NSNumber *itemsPurchasedSinceInApp = [defaults objectForKey:YRDItemsPurchasedSinceInAppDefaultsKey];
	if (itemsPurchasedSinceInApp != nil) {
		itemsPurchasedSinceInApp = @([itemsPurchasedSinceInApp integerValue] + 1);
		[defaults setObject:itemsPurchasedSinceInApp forKey:YRDItemsPurchasedSinceInAppDefaultsKey];
	}
	
	NSString *conversionMessageId = [_conversionTracker checkItemConversion:item];
	
	
	NSArray *currencyArray = [_currencyTracker currencyDictionaryToArray:currencies];
	
	// send track virtual purchase
	YRDVirtualPurchase *purchase = [[YRDVirtualPurchase alloc] init];
	purchase.item = item;
	purchase.currencies = currencyArray;
	purchase.onSale = onSale;
	purchase.firstPurchase = itemsPurchased == 1;
	purchase.purchasesSinceInApp = itemsPurchasedSinceInApp;
	purchase.conversionMessageId = conversionMessageId;
	[_purchaseSubmitter addVirtualPurchase:purchase];
	
	// update currencies
	[_currencyTracker spentCurrencies:currencies];
}

- (void)purchasedInApp:(YRDPurchase *)purchase
{
	VALIDATE_ARG_NON_NIL(@"reporting in-app purchase", purchase);
	[self purchasedInApp:purchase currencies:nil];
}

- (void)purchasedInApp:(YRDPurchase *)purchase currency:(NSString *)currency amount:(NSInteger)amount
{
	VALIDATE_ARG_NON_NIL(@"reporting in-app purchase", purchase);
	[self purchasedInApp:purchase currencies:@{ currency : @(amount) }];
}

- (void)purchasedInApp:(YRDPurchase *)purchase currencies:(NSDictionary *)currencies
{
	VALIDATE_ARG_NON_NIL(@"reporting in-app purchase", purchase);
	
	NSArray *currencyArray = [_currencyTracker currencyDictionaryToArray:currencies];
	NSInteger itemsPurchased = [[YRDDataStore sharedDataStore] integerForKey:YRDItemsPurchasedDefaultsKey];
	
	NSString *conversionMessageId = [_conversionTracker checkInAppConversion:purchase.productIdentifier];
	
	NSInteger totalLaunchCount = _launchTracker.totalLaunchCount;
	NSTimeInterval timePlayed = _timeTracker.timePlayed;
	NSArray *currencyBalance = _currencyTracker.currencyBalance,
			*currencyEarned = _currencyTracker.currencyEarned,
			*currencySpent = _currencyTracker.currencySpent,
			*currencyPurchased = _currencyTracker.currencyPurchased;
	
	NSArray *lastFeatureUses = _historyTracker.lastFeatureUses,
			*lastItemPurchases = _historyTracker.lastItemPurchases,
			*lastMessages = _historyTracker.lastMessages,
			*lastPlayerProgressionCategories = _historyTracker.lastPlayerProgressionCategories,
			*lastPlayerProgressionMilestones = _historyTracker.lastPlayerProgressionMilestones,
			*lastFeatureNames = _historyTracker.lastFeatureNames,
			*lastFeatureLevels = _historyTracker.lastFeatureLevels;
	
	[purchase completeObjectWithCompletionHandler:^(BOOL success) {
		YRDTrackPurchaseRequest *request = [YRDTrackPurchaseRequest requestWithPurchase:purchase
																			   currency:currencyArray
																			   launches:totalLaunchCount
																			   playtime:timePlayed
																		currencyBalance:currencyBalance
																		 earnedCurrency:currencyEarned
																		  spentCurrency:currencySpent
																	  purchasedCurrency:currencyPurchased
																		 itemsPurchased:itemsPurchased
																	conversionMessageId:conversionMessageId
																		lastFeatureUses:lastFeatureUses
																	  lastItemPurchases:lastItemPurchases
																		   lastMessages:lastMessages
														lastPlayerProgressionCategories:lastPlayerProgressionCategories
														lastPlayerProgressionMilestones:lastPlayerProgressionMilestones
																	   lastFeatureNames:lastFeatureNames
																	  lastFeatureLevels:lastFeatureLevels];
		[_purchaseSubmitter addPurchaseRequest:request];
	}];
	
	[_currencyTracker purchasedCurrencies:currencies];
}

#pragma mark - Existing users

- (void)setPreYerdyUser:(BOOL)existingUser
{
	[self setPersistentObject:@(existingUser) forKey:YRDIsUserExistingUserDefaultsKey];
}

- (BOOL)isPreYerdyUser
{
	return [[self persistentObjectForKey:YRDIsUserExistingUserDefaultsKey] boolValue];
}

- (void)setExistingCurrenciesForPreYerdyUser:(NSDictionary *)existingCurrencies
{
	VALIDATE_ARG_NON_NIL(@"setting existing currencies", existingCurrencies);
	
	BOOL applied = [[self persistentObjectForKey:YRDAppliedExistingCurrencyDefaultsKey] boolValue];
	if (!applied) {
		self.preYerdyUser = YES;
		
		[_currencyTracker earnedCurrencies:existingCurrencies];
		[self setPersistentObject:@YES forKey:YRDAppliedExistingCurrencyDefaultsKey];
		[[YRDDataStore sharedDataStore] synchronize];
		
		if (_sentLaunchCall) {
			// refresh our currency on the server
			YRDDebug(@"Reporting existing currency...");
			YRDLaunchRequest *launchRequest = [YRDLaunchRequest launchRequestWithToken:self.pushToken
																			  launches:_launchTracker.versionLaunchCount
																			   crashes:_launchTracker.versionCrashCount
																			  playtime:_timeTracker.versionTimePlayed
																			  currency:_currencyTracker.currencyBalance
																		  screenVisits:_screenVisitTracker.loggedScreenVisits
																			adRequests:_adRequestTracker.adRequests
																			   adFills:_adRequestTracker.adFills
																			   refresh:YES];
			[YRDURLConnection sendRequest:launchRequest completionHandler:^(YRDLaunchResponse *response, NSError *error) {
				if (response.success) {
					YRDDebug(@"Reported existing currency");
				} else {
					YRDDebug(@"Failed to report existing currency: %@", error);
				}
			}];
		}
	}
}

#pragma mark - Player Progression

- (void)startPlayerProgression:(NSString *)category initialMilestone:(NSString *)milestone
{
	VALIDATE_ARG_NON_NIL(@"starting player progression", category);
	VALIDATE_ARG_NON_NIL(@"starting player progression", milestone);
	
	[_progressionTracker startPlayerProgression:category initialMilestone:milestone];
}

- (void)logPlayerProgression:(NSString *)category milestone:(NSString *)milestone
{
	VALIDATE_ARG_NON_NIL(@"logging player progression", category);
	VALIDATE_ARG_NON_NIL(@"logging player progression", milestone);
	
	[_progressionTracker logPlayerProgression:category milestone:milestone];
}

#pragma mark - Feature use

- (void)logFeatureUse:(NSString *)feature
{
	VALIDATE_ARG_NON_NIL(@"logging feature use", feature)
	
	[_screenVisitTracker logScreenVisit:feature];
	[_featureMasteryTracker logFeatureUse:feature];
}

- (void)setFeatureUsesForNovice:(int)novice amateur:(int)amateur master:(int)master
{
	[_featureMasteryTracker setFeatureUsesForNovice:novice amateur:amateur master:master];
}

- (void)setFeatureUsesForNovice:(int)novice amateur:(int)amateur master:(int)master forFeature:(NSString *)feature
{
	[_featureMasteryTracker setFeatureUsesForNovice:novice amateur:amateur master:master forFeature:feature];
}

#pragma mark - Events

- (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters
{
	VALIDATE_ARG_NON_NIL(@"logging event", eventName);
	
	// Put it in the '0' bucket for now... (maybe change later? - talk to Michal)
	YRDCounterEvent *event = [[YRDCounterEvent alloc] initWithType:YRDCounterTypeCustom
															  name:eventName
															 value:@"0"];
	
	for (NSString *paramName in parameters) {
		if ([paramName isEqualToString:eventName]) {
			YRDError(@"logEvent: Parameter name (%@) must not be the same as event name (%@). "
					 @"Discarding parameter...", paramName, eventName);
			continue;
		}
		NSString *value = [NSString stringWithFormat:@"_%@", parameters[paramName]];
		[event setValue:value forParameter:paramName];
	}
	
	[_trackCounterBatcher addEvent:event];
}

#pragma mark - Ad tracking

- (void)logAdRequest:(NSString *)adNetworkName
{
	VALIDATE_ARG_NON_NIL(@"logging ad request", adNetworkName);
	[_adRequestTracker logAdRequest:adNetworkName];
}

- (void)logAdFill:(NSString *)adNetworkName
{
	VALIDATE_ARG_NON_NIL(@"logging ad fill", adNetworkName);
	[_adRequestTracker logAdFill:adNetworkName];
}

@end
