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


@implementation YRDTrackPurchaseRequest

+ (instancetype)requestWithPurchase:(YRDPurchase *)purchase
						   currency:(NSArray *)currency
						   launches:(int)launchCount
						   playtime:(NSTimeInterval)playtime
					 earnedCurrency:(NSArray *)earnedCurrency
					  spentCurrency:(NSArray *)spentCurrency
				  purchasedCurrency:(NSArray *)purchasedCurrency
					 itemsPurchased:(int)itemsPurchased
{
	// TODO: Build parameters/body
	NSDictionary *query = @{};
	
	YRDTrackPurchaseRequest *request = [[self alloc] initWithPath:@"" queryParameters:query];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDTrackPurchaseResponse class]];
	return request;
}

@end
