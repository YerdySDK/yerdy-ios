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

- (void)yerdy:(Yerdy *)yerdy handleInAppPurchase:(YRDInAppPurchase *)purchase;
- (void)yerdy:(Yerdy *)yerdy handleItemPurchase:(YRDItemPurchase *)purchase;
- (void)yerdy:(Yerdy *)yerdy handleReward:(YRDReward *)reward;

@end