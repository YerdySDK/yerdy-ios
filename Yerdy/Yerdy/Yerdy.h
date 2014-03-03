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

@interface Yerdy : NSObject

+ (instancetype)startWithPublisherKey:(NSString *)key;
+ (instancetype)sharedYerdy;

@property (nonatomic, weak) id<YerdyDelegate> delegate;
@property (nonatomic, weak) id<YerdyMessageDelegate> messageDelegate;

// Sets or retrieves the users push notification token
@property (nonatomic, copy) NSData *pushToken;

// Is the user a premium user? (Do they have any validated IAP purchases?)
@property (nonatomic, readonly) BOOL isPremiumUser;

// Is a message available for the passed in placement?
//
// TODO: How to handle nil?
- (BOOL)messageAvailable:(NSString *)placement;

// Show message for placement.
// Equivalent to [yerdy showMessage:placement inWindow:nil]
- (BOOL)showMessage:(NSString *)placement;

// Show message for placement in the specified UIWindow
// If 'window' is nil, defaults to the application's keyWindow
//
// TODO: How to handle nil for 'placement'?
- (BOOL)showMessage:(NSString *)placement inWindow:(UIWindow *)window;


// TODO: Document these!
- (void)registerCurrencies:(NSArray *)currencies;

- (void)earnedCurrency:(NSString *)currency amount:(NSUInteger)amount;
- (void)earnedCurrencies:(NSDictionary *)currencies;

- (void)purchasedItem:(NSString *)item withCurrency:(NSString *)currency amount:(NSUInteger)amount;
- (void)purchasedItem:(NSString *)item withCurrencies:(NSDictionary *)currencies;

- (void)purchasedInApp:(YRDPurchase *)purchase;
- (void)purchasedInApp:(YRDPurchase *)purchase currency:(NSString *)currency amount:(NSUInteger)amount;
- (void)purchasedInApp:(YRDPurchase *)purchase currencies:(NSDictionary *)currencies;

@end
