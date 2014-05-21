//
//  YerdyDelegate.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YRDInAppPurchase.h"
#import "YRDItemPurchase.h"
#import "YRDReward.h"

@class Yerdy;

/** Defines global Yerdy callbacks
 
 */

@protocol YerdyDelegate <NSObject>
@optional

/** Called when a launch has been successfully reported to the Yerdy servers
 
 This method is also called when new messages are received (on subsequent resumes
 of the app if enough time has passed)
 
 */
- (void)yerdyConnected;

@end



/** Defines all the messaging related delegate methods
 
 ### Messaging Lifecycle ###

 *App requests that a message be shown*
 
 - `-yerdy:willPresentMessageForPlacement:`
 
 *Message is presented*
 
 - `-yerdy:didPresentMessageForPlacement:`
 
 *User interacts with message*
 
 - `-yerdy:willDismissMessageForPlacement:`
 
 *Message is dismissed*
 
 - `-yerdy:didDismissMessageForPlacement:`
 
 *If the message has action that the app should handle, one of:*
 
 - `-yerdy:handleInAppPurchase:`
 - `-yerdy:handleItemPurchase:`
 - `-yerdy:handleReward:`
 - `-yerdy:handleNavigation:`
 
 */

@protocol YerdyMessageDelegate <NSObject>
@optional

/** Called right before a message is presented
 
 @param yerdy The shared Yerdy instance
 @param placement The placement passed in to `-[Yerdy showMessage:]`
 
 @see yerdy:didPresentMessageForPlacement:
 
 */
- (void)yerdy:(Yerdy *)yerdy willPresentMessageForPlacement:(NSString *)placement;

/** Called right after a message is presented (i.e. after it has animated in)
 
 @param yerdy The shared Yerdy instance
 @param placement The placement passed in to `-[Yerdy showMessage:]`
 
 @see yerdy:willPresentMessageForPlacement:
 
 */
- (void)yerdy:(Yerdy *)yerdy didPresentMessageForPlacement:(NSString *)placement;

/** Called after a user has tapped a button but before the message has been dismissed
 
 @param yerdy The shared Yerdy instance
 @param placement The placement passed in to `-[Yerdy showMessage:]`
 
 @see yerdy:didDismissMessageForPlacement:
 
 */
- (void)yerdy:(Yerdy *)yerdy willDismissMessageForPlacement:(NSString *)placement;

/** Called after a message has been dismissed (i.e. after it has animated out)
 
 @param yerdy The shared Yerdy instance
 @param placement The placement passed in to `-[Yerdy showMessage:]`
 
 @see yerdy:willDismissMessageForPlacement:
 
 */
- (void)yerdy:(Yerdy *)yerdy didDismissMessageForPlacement:(NSString *)placement;

/** Called when your app should handle an in-app purchase
 
 @param yerdy The shared Yerdy instance
 @param purchase An object containing the product identifier for the in-app purchase
 
 */
- (void)yerdy:(Yerdy *)yerdy handleInAppPurchase:(YRDInAppPurchase *)purchase;
 
/** Called when your app should handle an in-game item purchase
 
 @param yerdy The shared Yerdy instance
 @param purchase An object containing the name of the in-game item to purchase
 
 */
- (void)yerdy:(Yerdy *)yerdy handleItemPurchase:(YRDItemPurchase *)purchase;

/** Called when your app should handle a reward
 
 @param yerdy The shared Yerdy instance
 @param reward An object containing the rewards for the user
 
 */
- (void)yerdy:(Yerdy *)yerdy handleReward:(YRDReward *)reward;

/** Called when your app should navigate to a screen (from a pull message)
 
 @param yerdy The shared Yerdy instance
 @param screenName The name of the screen to navigate to
 
 */
- (void)yerdy:(Yerdy *)yerdy handleNavigation:(NSString *)screenName;

@end
