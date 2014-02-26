//
//  YRDTrackVirtualPurchaseRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTrackVirtualPurchaseRequest.h"
#import "YRDJSONResponseHandler.h"
#import "YRDTrackVirtualPurchaseResponse.h"

@implementation YRDTrackVirtualPurchaseRequest

+ (instancetype)requestWithItem:(NSString *)item price:(NSArray *)currencies firstPurchase:(BOOL)firstPurchase
{
	// TODO: add parameters
	
	NSDictionary *query = @{};
	YRDTrackVirtualPurchaseRequest *request = [[self alloc] initWithPath:@"stats/trackVirtualPurchase.php"
														 queryParameters:query];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDTrackVirtualPurchaseResponse class]];
	return request;
}

@end
