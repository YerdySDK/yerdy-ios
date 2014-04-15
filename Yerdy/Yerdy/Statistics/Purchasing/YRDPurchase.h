//
//  YRDPurchase.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-25.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


@interface YRDPurchase : NSObject

@property (nonatomic, readonly) NSString *productIdentifier;
@property (nonatomic, readonly) NSData *receipt;

@property (nonatomic, readonly) NSString *price;
@property (nonatomic, readonly) NSString *currencyCode;
@property (nonatomic, readonly) NSString *storeCountryCode;

// Optional, set this to YES to track this IAP purchase as being "on sale"
// Defaults to NO
@property (nonatomic, assign, getter = isOnSale) BOOL onSale;


+ (instancetype)purchaseWithTransaction:(SKPaymentTransaction *)transaction;
+ (instancetype)purchaseWithProduct:(SKProduct *)product transaction:(SKPaymentTransaction *)transaction;

+ (instancetype)purchaseWithProductIdentifier:(NSString *)productIdentifier
									  receipt:(NSData *)receipt
										price:(NSString *)price			// i.e.: @"0.99"
								 currencyCode:(NSString *)currencyCode	// ISO 4217 currency code
							 storeCountryCode:(NSString *)storeCountryCode;	// adheres to ISO 3166-1_alpha-2

@end
