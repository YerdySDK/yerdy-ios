//
//  YRDTrackVirtualPurchaseRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackVirtualPurchaseRequest.h"
#import "YRDJSONResponseHandler.h"
#import "YRDTrackPurchaseResponse.h"
#import "Yerdy_Private.h"
#import "YRDUtil.h"

@implementation YRDTrackVirtualPurchaseRequest

+ (instancetype)requestWithItem:(NSString *)item price:(NSArray *)currencies onSale:(BOOL)onSale
				  firstPurchase:(BOOL)firstPurchase purchasesSinceInApp:(NSNumber *)purchasesSinceInApp
{
	NSString *currencyString = [currencies componentsJoinedByString:@";"];
	
	NSMutableDictionary *query = [@{
		@"itemid" : YRDToString(item),
		@"first" : @(firstPurchase),
		@"currency" : YRDToString(currencyString),
		@"tag" : YRDToString([Yerdy sharedYerdy].ABTag),
		@"api" : @3,
		@"sale" : @(onSale),
	} mutableCopy];
	
	if (purchasesSinceInApp)
		query[@"indexiap"] = purchasesSinceInApp;
	
	YRDTrackVirtualPurchaseRequest *request = [[self alloc] initWithPath:@"stats/trackVirtualPurchase.php"
														 queryParameters:query];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDTrackPurchaseResponse class]];
	return request;
}

@end
