//
//  YRDTrackPurchaseRequest.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDRequest.h"

@class YRDPurchase;


@interface YRDTrackPurchaseRequest : YRDRequest

+ (instancetype)requestWithPurchase:(YRDPurchase *)purchase
						   currency:(NSArray *)currency
						   launches:(NSInteger)launchCount
						   playtime:(NSTimeInterval)playtime
					currencyBalance:(NSArray *)currencyBalance
					 earnedCurrency:(NSArray *)earnedCurrency
					  spentCurrency:(NSArray *)spentCurrency
				  purchasedCurrency:(NSArray *)purchasedCurrency
					 itemsPurchased:(NSInteger)itemsPurchased
				conversionMessageId:(NSString *)conversionMessageId;

@end
