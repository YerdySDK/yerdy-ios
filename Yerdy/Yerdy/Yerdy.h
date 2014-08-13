//
//  Yerdy.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YerdyDelegate.h"
#import "YRDPurchase.h"
#import "YRDLogLevel.h"

/** Public interface to Yerdy
 
 <a name="messaging"></a>
 ## Messaging ##
 
 Yerdy can be used to show users messages configured in the dashboard.  See below for implementation details.
 
 ### Placements ###
 
 Using placements you can target different messages to different places inside your game. For example,
 you could add a `level_complete` placement and then setup a daily message rewarding the user for 
 completing a level to encourage users to complete a level daily.
 
 Some examples placements could include `launch`, `game_over`, `level_complete`, and `achievement_unlocked`
 
 **Note:** *Placements are optional. If you wish to show any message regardless of placement you can simply 
 pass in `nil` to most methods taking a placement.*
 
 ### Showing messages ###
 
 To show a message, simply call `showMessage:`, passing in a placement:
 
	[[Yerdy sharedYerdy] showMessage:@"launch"];
 
 If you wish to check if a messsage is available before trying to show one, you can use `isMessageAvailable:`:

	if ([[Yerdy sharedYerdy] isMessageAvailable:@"launch"]) {
		[[Yerdy sharedYerdy] showMessage:@"launch"];
	} else {
		NSLog(@"No message available");
	}
 
 ### Handling message triggered rewards and purchases
 
 An important part of Yerdy's messaging features is being able to reward the user or trigger a purchase
 inside the app (for example, when an item is on sale).  To support this, you need to implement a few
 methods in the `YerdyMessageDelegate` protocol and set your object as the `messageDelegate`:
 
	- (void)yerdy:(Yerdy *)yerdy handleReward:(YRDReward *)reward
	{
		NSDictionary *rewards = reward.rewards;
		
		// 'rewards' is a dictionary contain reward names & amounts, like:
		//	@{ @"bricks" : @5 }
		// For example, if you have a class 'InventoryManager' used for tracking the user's inventory,
		// you could do something like:
		
		for (NSString *rewardName in rewards) {
			NSNumber *count = rewards[rewardName];
			[[InventoryManager sharedManager] addItem:rewardName count:count.intValue];
		}
	}
 
	- (void)yerdy:(Yerdy *)yerdy handleInAppPurchase:(YRDInAppPurchase *)purchase
	{
		// 'purchase' contains a product identifer you can use to start an in-app purchase.
		// For example, if you have a class 'InAppManager' used for handling in app purchases,
		// you could do something like:
		
		[[InAppManager sharedManager] startInAppPurchase:purchase.productIdentifier];
	}
 
	- (void)yerdy:(Yerdy *)yerdy handleItemPurchase:(YRDItemPurchase *)purchase
	{
		// 'purchase' contains a product identifer you can use to start an in-game item purchase
		// For example, if you have a class 'StoreManager' used for purchasing in game items,
		// you could do something like:
 
		[[StoreManager sharedManager] purchaseItem:purchase.item];
	}
 
 <a name="currencies"></a>
 ## In-Game Currency ##
 
 Yerdy can be used to track the economy of your game.  See below for implementation details.
 
 ### Registering Currencies ###
 
 You can register up to 6 currencies via the `configureCurrencies:` method. For example:
 
	// Currency 1 -> Gold
	// Currency 2 -> Silver
	// Currency 3 -> Bronze
	[[Yerdy sharedYerdy] configureCurrencies:@[ @"Gold", @"Silver", @"Bronze" ]];
 
 **Note:** The order of the currencies is important. You **MUST NOT** reorder them. However,
 you can append new currencies.  For example, if we add a new currency to our game in
 a later release, we would update the array to:
 `@[ @"Gold", @"Silver", @"Bronze", @"Rubies" ]`
 
 ### Reporting In-Game Currency Transactions ###
 
 Yerdy supports three types of transactions:
 
 - User earned currency (`earnedCurrencies:`)
 - User purchased an in game item (`purchasedItem:withCurrencies:`)
 - User made an in-app purchase (`purchasedInApp:currencies:`)
 
 All three of these methods accept a dictionary of currencies and their amounts. Some examples:
 
 #### User earned currency ####
 
	NSDictionary *earnedAmounts = @{
		@"Gold" : @10,
		@"Silver" : @5,
	};
	[[Yerdy sharedYerdy] earnedCurrencies:earnedAmounts];
 
 #### User purchase an in game item ####
 
	NSDictionary *itemPrice = @{
		@"Silver" : @5,
	};
	[[Yerdy sharedYerdy] purchasedItem:@"Superboost" withCurrencies:itemPrice];
 
 #### User made an in-app purchase ####
 
 For example, if the user bought a "Starter Bundle" that gave them 5 gold, 10 silver, and 15 bronze:

	SKPaymentTransaction *transaction = ...; // SKPaymentTransaction from StoreKit
	YRDPurchase *purchase = [YRDPurchase purchaseWithTransaction:transaction];
	NSDictionary *amount = @{
		@"Gold" : @5,
		@"Silver" : @10,
		@"Bronze" : @15,
	};
	[[Yerdy sharedYerdy] purchasedInApp:purchase currencies:amount];
 
 */

@interface Yerdy : NSObject

/*******************************************************************************
 @name Static Methods
 */

/** Starts Yerdy
 
 @param key Your publisher key (get one from [here](http://www.yerdy.com))
 
 @return The newly created instance of Yerdy
 */
+ (instancetype)startWithPublisherKey:(NSString *)key;

/** Gets the singleton instance of Yerdy.
 
 @return Shared instance of Yerdy
 
 @warning You *must* start Yerdy first with startWithPublisherKey:
 
 @see startWithPublisherKey:
 */
+ (instancetype)sharedYerdy;

/** Sets the log level
 
 @param logLevel The log level.  It is recommended you keep at very least default (YRDLogWarn)
 
 @see YRDLogLevel
 */
+ (void)setLogLevel:(YRDLogLevel)logLevel;

/*******************************************************************************
 @name Properties
 */

/**
 @see YerdyDelegate
 */
@property (nonatomic, weak) id<YerdyDelegate> delegate;

/**
 @see YerdyMessageDelegate
 */
@property (nonatomic, weak) id<YerdyMessageDelegate> messageDelegate;

/** Sets the user's push token
 
 Example Usage:
 
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		// Application setup, Yerdy setup, etc...
		[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
	}
	
	- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
	{
		[Yerdy sharedYerdy].pushToken = deviceToken;
	}
 
 */
@property (nonatomic, copy) NSData *pushToken;

/** Is the user a premium user? (Do they have any validated IAP purchases?)
 */
@property (nonatomic, readonly) BOOL isPremiumUser;


/*******************************************************************************
 * @name Messaging
 */


/** Checks if a message is available for the given placement
 
 @param placement The placement (for example, you could have "launch", "gameover", and "store").  Pass in nil for any placement.
 
 @return Whether or not a message is available
 
 */
- (BOOL)isMessageAvailable:(NSString *)placement;

/** Shows a message (if available)
 
 Equivalent to `showMessage:inWindow:` with a `nil` window
 
 @param placement The placement (for example, you could have "launch", "gameover", and "store").  Pass in nil for any placement.
 
 @return Whether or not a message was shown
 
 @see isMessageAvailable:
 @see showMessage:inWindow:
 
 @warning This method presents the message in the applications keyWindow.  You should instead pass in the UIWindow you created to showMessage:inWindow:
 
 */
- (BOOL)showMessage:(NSString *)placement;

/** Shows a message (if available)
 
 @param placement The placement (for example, you could have "launch", "gameover", and "store").  Pass in nil for any placement.
 @param window The UIWindow you want to present the message in
 
 @return Whether or not a message was shown
 
 @see isMessageAvailable:
 @see showMessage:
 */
- (BOOL)showMessage:(NSString *)placement inWindow:(UIWindow *)window;

/** Dismisses any open messages
 */
- (void)dismissMessage;


/*******************************************************************************
 * @name Currency
 */

/** Registers up to 6 currencies used in the app.
 
 See [In-Game Currency](#currencies) for more details.
 
 @param currencies An array `NSString`'s containing the names of currencies in your app
 
 @warning You **MUST NOT** change the order of currencies.  However, you may append new currencies.
 */
- (void)configureCurrencies:(NSArray *)currencies;

/** Tracks currency earned by the user.
 
 See [In-Game Currency](#currencies) for more details.
 
 @param currency The name of the currency
 @param amount The amount of currency earned (must be positive!)
 
 @see earnedCurrencies:
 */
- (void)earnedCurrency:(NSString *)currency amount:(NSInteger)amount;

/** Tracks currency earned by the user.
 
 See [In-Game Currency](#currencies) for more details.
 
 @param currencies A dictionary mapping currency names (`NSString`'s) to amounts (`NSNumber`'s). All amounts must be positive!
 
 @see earnedCurrency:amount:
 */
- (void)earnedCurrencies:(NSDictionary *)currencies;

/** Tracks in-game item purchase
 
 See [In-Game Currency](#currencies) for more details.
 
 @param item The name of the item
 @param currency The name of the currency used to purchase the item
 @param amount The amount of currency used to purchase the item (must be positive!)
 
 @see purchasedItem:withCurrencies:
 @see purchasedItem:withCurrencies:onSale:
 */
- (void)purchasedItem:(NSString *)item withCurrency:(NSString *)currency amount:(NSInteger)amount;

/** Tracks in-game item purchase
 
 See [In-Game Currency](#currencies) for more details.
 
 @param item The name of the item
 @param currencies A dictionary mapping currency names (`NSString`'s) to amounts (`NSNumber`'s). All amounts must be positive!
 
 @see purchasedItem:withCurrency:amount:
 @see purchasedItem:withCurrencies:onSale:
 */
- (void)purchasedItem:(NSString *)item withCurrencies:(NSDictionary *)currencies;

/** Tracks in-game item purchase
 
 See [In-Game Currency](#currencies) for more details.
 
 @param item The name of the item
 @param currencies A dictionary mapping currency names (`NSString`'s) to amounts (`NSNumber`'s). All amounts must be positive!
 @param onSale Whether or not the item is on sale
 
 @see purchasedItem:withCurrency:amount:
 @see purchasedItem:withCurrencies:
 */
- (void)purchasedItem:(NSString *)item withCurrencies:(NSDictionary *)currencies onSale:(BOOL)onSale;

/** Tracks in-app purchases (IAP)
 
 If the in-app purchase was for in-game currency, use `purchasedInApp:currency:amount:` 
 or `purchasedInApp:currencies:` instead.
 
 See [In-Game Currency](#currencies) for more details.
 
 @param purchase A YRDPurchase instance describing the purchase
 
 @see purchasedInApp:currency:amount:
 @see purchasedInApp:currencies:
 @see YRDPurchase
 */
- (void)purchasedInApp:(YRDPurchase *)purchase;

/** Tracks in-app purchases (IAP)
 
 Use this method to report in app purchases for in-game currency
 
 See [In-Game Currency](#currencies) for more details.
 
 @param purchase A YRDPurchase instance describing the purchase
 @param currency The name of the currency that was purchased
 @param amount The amount of currency that was purchased (must be positive!)
 
 @see purchasedInApp:
 @see purchasedInApp:currencies:
 @see YRDPurchase
 */
- (void)purchasedInApp:(YRDPurchase *)purchase currency:(NSString *)currency amount:(NSInteger)amount;

/** Tracks in-app purchases (IAP)
 
 Use this method to report in app purchases for in-game currency(s)
 
 See [In-Game Currency](#currencies) for more details.
 
 @param purchase A YRDPurchase instance describing the purchase
 @param currencies A dictionary mapping currency names (`NSString`'s) to amounts (`NSNumber`'s).  All amounts must be positive!
 
 @see purchasedInApp:
 @see purchasedInApp:currency:amount:
 @see YRDPurchase
 */
- (void)purchasedInApp:(YRDPurchase *)purchase currencies:(NSDictionary *)currencies;


/** Marks whether a user is an existing user or not
 
 Certain types of metrics aren't tracked for existing users (for example, metrics
 tracked at certain time intervals after install)
 
 @warning If the user has any existing currency, you must use `setExistingCurrenciesForPreYerdyUser:` to ensure
	currency tracking is correct
 
 @see shouldTrackPreYerdyUsersProgression
 @see setExistingCurrenciesForPreYerdyUser:
 */
@property (nonatomic, assign, getter = isPreYerdyUser) BOOL preYerdyUser;

/** Overrides the default behaviour of not tracking certain metrics when `preYerdyUser` is `YES`
 
 @see preYerdyUser
 */
@property (nonatomic, assign) BOOL shouldTrackPreYerdyUsersProgression;

/** Marks a user as existing and sets their existing currency
 
 @param existingCurrencies The users current currency balance (see [In-Game Currency](#currencies) for more details)
 
 @see preYerdyUser
 */
- (void)setExistingCurrenciesForPreYerdyUser:(NSDictionary *)existingCurrencies;

/*******************************************************************************
 @name Event tracking
 */

/** Starts a player progression category
 
 Milestones are grouped by category.  For example, you may have a 'map' category and your milestones
 could be 'unlocked world 1', 'unlocked world 2', 'unlocked world 3', etc...
 
 Use this method to log the first milestone in a player progression category, and
 then `logPlayerProgression:milestone` for any subsequent events
 
 @param category The category for this progression event
 @param milestone The milestone the user reached
 
 @see logPlayerProgression:milestone:
 
 */
- (void)startPlayerProgression:(NSString *)category initialMilestone:(NSString *)milestone;

/** Logs a player progression event.
 
 Milestones are grouped by category.  For example, you may have a 'map' category and your milestones
 could be 'unlocked world 1', 'unlocked world 2', 'unlocked world 3', etc...
 
 You must log the first milestone using `startPlayerProgression:initialMilestone:`, and any
 subsequent milestones using this method
 
 @param category The category for this progression event
 @param milestone The milestone the user reached
 
 @see startPlayerProgression:initialMilestone:
 
 */
- (void)logPlayerProgression:(NSString *)category milestone:(NSString *)milestone;

/** Tracks a screen visit
 
 Use this method to track screen visits
 
 @param screenName The name of the screen (for example: "settings", "store", etc...)
 
 */
- (void)logScreenVisit:(NSString *)screenName;

/** Tracks a user-defined event
 
 *This feature is currently only supported by Premium Yerdy Accounts.*
 
 Used to track any other metrics you may find interesting.  For example, you could have an event
 to see which character is selected most often:
 
	[[Yerdy sharedYerdy] logEvent:@"CharacterSelected" parameters:@{ @"Name" : @"Bob" }];
 
 @param eventName The name of the event
 @param parameters Any parameters for the event (both keys and values must be NSString)
 
 */
- (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;

/** Tracks an ad request.
 
 When the ad network comes back with an ad, you need to call logAdFill: with the same
 ad network name.  For example, if you wanted to track iAd interstitial requests/fills:
 
	- (void)requestAd
	{
		_interstitial = [[ADInterstitialAd alloc] init];
		_interstitial.delegate = self;
 
		[[Yerdy sharedYerdy] logAdRequest:@"iAd"];
	}
 
	- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
	{
		[[Yerdy sharedYerdy] logAdFill:@"iAd"];  // NOTE: Exact same string used above for logAdRequest:
	}
 
 @param adNetworkName The name of ad network
 
 @see logAdFill:
 
 */
- (void)logAdRequest:(NSString *)adNetworkName;

/** Tracks an ad fill.
 
 See logAdRequest: for an example.
 
 @param adNetworkName The name of ad network
 
 @see logAdRequest:
 
 */
- (void)logAdFill:(NSString *)adNetworkName;

@end
