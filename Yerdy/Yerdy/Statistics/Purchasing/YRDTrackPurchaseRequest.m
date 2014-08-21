//
//  YRDTrackPurchaseRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackPurchaseRequest.h"
#import "YRDJSONResponseHandler.h"
#import "YRDPurchase.h"
#import "YRDTrackPurchaseResponse.h"
#import "YRDUtil.h"
#import "Yerdy_Private.h"


@implementation YRDTrackPurchaseRequest

+ (instancetype)requestWithPurchase:(YRDPurchase *)purchase
						   currency:(NSArray *)currency
						   launches:(NSInteger)launchCount
						   playtime:(NSTimeInterval)playtime
					currencyBalance:(NSArray *)currencyBalance
					 earnedCurrency:(NSArray *)earnedCurrency
					  spentCurrency:(NSArray *)spentCurrency
				  purchasedCurrency:(NSArray *)purchasedCurrency
					 itemsPurchased:(NSInteger)itemsPurchased
				conversionMessageId:(NSString *)conversionMessageId
				   lastScreenVisits:(NSArray *)lastScreenVisits
				  lastItemPurchases:(NSArray *)lastItemPurchases
					   lastMessages:(NSArray *)lastMessages
	lastPlayerProgressionCategories:(NSArray *)lastPlayerProgressionCategories
	lastPlayerProgressionMilestones:(NSArray *)lastPlayerProgressionMilestones
{
	UIDevice *device = [UIDevice currentDevice];
	NSString *os = [NSString stringWithFormat:@"%@ %@", device.systemName, device.systemVersion];
		
	NSMutableDictionary *query = [@{
		@"os" : YRDToString(os),
		@"cc" : YRDToString(purchase.storeCountryCode),
		@"currency" : [self currencyString:currency],
		@"sale" : @(purchase.isOnSale),
		@"value" : [NSString stringWithFormat:@"%@%@", purchase.price, purchase.currencyCode],
		@"tag" : YRDToString([Yerdy sharedYerdy].ABTag),
		@"api" : @3
	} mutableCopy];
	
	if (conversionMessageId)
		query[@"msgid"] = conversionMessageId;
	
	NSMutableDictionary *body = [@{
		@"receipt" : YRDToString([YRDUtil base64String:purchase.receipt]),
		@"product" : YRDToString(purchase.productIdentifier),
		@"transaction" : YRDToString(purchase.transactionIdentifier),
		@"launch_count" : @(launchCount),
		@"playtime" : @((int)round(playtime)),
		@"currency" : [self currencyString:currencyBalance],
		@"currency_earned" : [self currencyString:earnedCurrency],
		@"currency_bought" : [self currencyString:purchasedCurrency],
		@"currency_spent" : [self currencyString:spentCurrency],
		@"items" : @(itemsPurchased),
	} mutableCopy];
	
	[body addEntriesFromDictionary:[self arrayParamsForItems:lastScreenVisits forKey:@"last_nav"]];
	[body addEntriesFromDictionary:[self arrayParamsForItems:lastItemPurchases forKey:@"last_item"]];
	[body addEntriesFromDictionary:[self arrayParamsForItems:lastMessages forKey:@"last_msg"]];
	[body addEntriesFromDictionary:[self arrayParamsForItems:lastPlayerProgressionCategories forKey:@"last_player_keys"]];
	[body addEntriesFromDictionary:[self arrayParamsForItems:lastPlayerProgressionMilestones forKey:@"last_player_values"]];
	
	YRDTrackPurchaseRequest *request = [[self alloc] initWithPath:@"stats/trackPurchase.php" queryParameters:query bodyParameters:body];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDTrackPurchaseResponse class]];
	return request;
}

+ (NSString *)currencyString:(NSArray *)currencies
{
	return YRDToString([currencies componentsJoinedByString:@";"]);
}

// makes a dictionary with values from an array in the form:
//	@{
//		@"<key>[0]" : item[0],
//		@"<key>[1]" : item[1]
//	}
+ (NSDictionary *)arrayParamsForItems:(NSArray *)items forKey:(NSString *)key
{
	NSMutableDictionary *retVal = [NSMutableDictionary dictionary];
	for (NSUInteger i = 0; i < items.count; i++) {
		NSString *k = [NSString stringWithFormat:@"%@[%lu]", key, (unsigned long)i];
		retVal[k] = [items[i] description];
 	}
	return retVal;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (!self)
		return nil;
	
	self.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDTrackPurchaseResponse class]];
	
	return self;
}

@end
