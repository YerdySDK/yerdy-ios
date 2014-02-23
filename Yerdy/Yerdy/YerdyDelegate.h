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


@protocol YerdyDelegate <NSObject>
@optional

// Called when a successful connection has been made to the Yerdy servers and
// messages have been downloaded
- (void)yerdyConnected;

@end





@protocol YerdyMessageDelegate <NSObject>
@optional

// Message lifecycle:
//
//	(app requests that a message be shown)
//
//	-yerdy:willPresentMessageForPlacement:
//	(message is presented)
//	-yerdy:didPresentMessageForPlacement:
//
//	(user interacts with message)
//
//	-yerdy:willDismissMessageForPlacement:
//	(message is dismissed)
//	-yerdy:didDismissMessageForPlacement:
//
//	(only if message has action that the app should handle)
//	-yerdy:handleInAppPurchase:
//	or -yerdy:handleItemPurchase:
//	or -yerdy:handleReward:


// Called right before a message is presented
- (void)yerdy:(Yerdy *)yerdy willPresentMessageForPlacement:(NSString *)placement;
// Called right after a message is presented (i.e. after it has animated in)
- (void)yerdy:(Yerdy *)yerdy didPresentMessageForPlacement:(NSString *)placement;

// Called after a user has tapped a button but before the message has been dismissed
- (void)yerdy:(Yerdy *)yerdy willDismissMessageForPlacement:(NSString *)placement;
// Called after a message has been dismissed (i.e. after it has animated out)
- (void)yerdy:(Yerdy *)yerdy didDismissMessageForPlacement:(NSString *)placement;

// Called when your app should handle an in app purchase, item purchase or rewards
- (void)yerdy:(Yerdy *)yerdy handleInAppPurchase:(YRDInAppPurchase *)purchase;
- (void)yerdy:(Yerdy *)yerdy handleItemPurchase:(YRDItemPurchase *)purchase;
- (void)yerdy:(Yerdy *)yerdy handleReward:(YRDReward *)reward;


// TODO: Add callbacks for internal web view??

@end
