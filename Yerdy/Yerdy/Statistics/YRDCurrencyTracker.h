//
//  YRDCurrencyTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-25.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRDCurrencyTracker : NSObject

- (void)registerCurrencies:(NSDictionary *)currencies;

// currencyEarned + currencyPurchased - currencySpent
@property (nonatomic, readonly) NSArray *currencyBalance;

@property (nonatomic, readonly) NSArray *currencyEarned;
@property (nonatomic, readonly) NSArray *currencySpent;
@property (nonatomic, readonly) NSArray *currencyPurchased;


- (void)earnedCurrency:(NSString *)currency amount:(NSUInteger)amount;
- (void)earnedCurrencies:(NSDictionary *)currencies;

- (void)spentCurrency:(NSString *)currency amount:(NSUInteger)amount;
- (void)spentCurrencies:(NSDictionary *)currencies;

- (void)purchasedCurrency:(NSString *)currency amount:(NSUInteger)amount;
- (void)purchasedCurrencies:(NSDictionary *)currencies;

@end
