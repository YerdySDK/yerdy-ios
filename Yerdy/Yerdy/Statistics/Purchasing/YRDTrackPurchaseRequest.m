//
//  YRDTrackPurchaseRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackPurchaseRequest.h"
#import "YRDTrackPurchaseResponse.h"
#import "YRDJSONResponseHandler.h"
#import "YRDPurchase.h"
#import "YRDUtil.h"
#import "Yerdy_Private.h"


@implementation YRDTrackPurchaseRequest

+ (instancetype)requestWithPurchase:(YRDPurchase *)purchase
						   currency:(NSArray *)currency
						   launches:(int)launchCount
						   playtime:(NSTimeInterval)playtime
					currencyBalance:(NSArray *)currencyBalance
					 earnedCurrency:(NSArray *)earnedCurrency
					  spentCurrency:(NSArray *)spentCurrency
				  purchasedCurrency:(NSArray *)purchasedCurrency
					 itemsPurchased:(int)itemsPurchased
{
	// TODO: Build body
	UIDevice *device = [UIDevice currentDevice];
	NSString *os = [NSString stringWithFormat:@"%@ %@", device.systemName, device.systemVersion];
		
	NSDictionary *query = @{
		@"os" : YRDToString(os),
		@"cc" : YRDToString(purchase.storeCountryCode),
		@"currency" : [self currencyString:currency],
		@"sale" : @(purchase.isOnSale),
		@"value" : [NSString stringWithFormat:@"%@%@", purchase.price, purchase.currencyCode],
		@"tag" : YRDToString([Yerdy sharedYerdy].ABTag),
		@"api" : @3
	};
	
	NSDictionary *body = @{
		@"receipt" : YRDToString([YRDUtil base64String:purchase.receipt]),
		@"product" : YRDToString(purchase.productIdentifier),
		@"sandbox" : @(purchase.isSandboxStore),
		@"launch_count" : @(launchCount),
		@"playtime" : @(playtime),
		@"currency" : [self currencyString:currencyBalance],
		@"currency_earned" : [self currencyString:earnedCurrency],
		@"currency_bought" : [self currencyString:purchasedCurrency],
		@"currency_spent" : [self currencyString:spentCurrency],
		@"items" : @(itemsPurchased),
	};
	
	YRDTrackPurchaseRequest *request = [[self alloc] initWithPath:@"stats/trackPurchase.php" queryParameters:query bodyParameters:body];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDTrackPurchaseResponse class]];
	return request;
}

+ (NSString *)currencyString:(NSArray *)currencies
{
	return YRDToString([currencies componentsJoinedByString:@";"]);
}

@end
