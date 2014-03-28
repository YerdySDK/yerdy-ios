//
//  YRDProductRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-04.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDProductRequest.h"

@interface YRDProductRequest () <SKProductsRequestDelegate>
{
	NSString *_productIdentifier;
	void(^_completionHandler)(SKProduct *);
	
	SKProductsRequest *_request;
}
@end


@implementation YRDProductRequest

+ (NSMutableSet *)activeRequests
{
	static NSMutableSet *activeRequests = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		activeRequests = [[NSMutableSet alloc] init];
	});
	
	return activeRequests;
}

+ (void)loadProduct:(NSString *)productIdentifier completionHandler:(void(^)(SKProduct *))completionHandler
{
	YRDProductRequest *request = [[YRDProductRequest alloc] initWithProductIdentifier:productIdentifier completionHandler:completionHandler];
	[[self activeRequests] addObject:request];
	[request start];
}

- (id)initWithProductIdentifier:(NSString *)productIdentifier completionHandler:(void(^)(SKProduct *))completionHandler
{
	self = [super init];
	if (!self)
		return nil;
	
	_productIdentifier = productIdentifier;
	_completionHandler = completionHandler;
	
	_request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productIdentifier]];
	_request.delegate = self;
	
	return self;
}

- (void)dealloc
{
	_request.delegate = nil;
}

- (void)start
{
	[_request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	NSUInteger productIndex = [response.products indexOfObjectPassingTest:^BOOL(SKProduct *product, NSUInteger idx, BOOL *stop) {
		return [product.productIdentifier isEqualToString:_productIdentifier];
	}];
	
	SKProduct *product = productIndex != NSNotFound ? response.products[productIndex] : nil;
	_completionHandler(product);
}

- (void)requestDidFinish:(SKRequest *)request
{
	[[[self class] activeRequests] removeObject:self];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	[[[self class] activeRequests] removeObject:self];
}

@end
