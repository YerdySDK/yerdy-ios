//
//  YRDPurchase.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-25.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDPurchase.h"
#import "YRDLog.h"
#import "YRDProductRequest.h"

@implementation YRDPurchase

+ (instancetype)purchaseWithTransaction:(SKPaymentTransaction *)transaction
{
	return [self purchaseWithProduct:nil transaction:transaction];
}

+ (instancetype)purchaseWithProduct:(SKProduct *)product transaction:(SKPaymentTransaction *)transaction
{
	return [self purchaseWithProductIdentifier:transaction.payment.productIdentifier
						 transactionIdentifier:transaction.transactionIdentifier
									   receipt:transaction.transactionReceipt
										 price:[product.price stringValue]
								  currencyCode:[product.priceLocale objectForKey:NSLocaleCurrencyCode]
							  storeCountryCode:[product.priceLocale objectForKey:NSLocaleCountryCode]];
}

+ (instancetype)purchaseWithProductIdentifier:(NSString *)productIdentifier
						transactionIdentifier:(NSString *)transactionIdentifier
									  receipt:(NSData *)receipt
										price:(NSString *)price
								 currencyCode:(NSString *)currencyCode
							 storeCountryCode:(NSString *)storeCountryCode
{
	return [[self alloc] initWithProductIdentifier:productIdentifier
							 transactionIdentifier:transactionIdentifier
										   receipt:receipt
											 price:price
									  currencyCode:currencyCode
								  storeCountryCode:storeCountryCode];
}

- (id)initWithProductIdentifier:(NSString *)productIdentifier
		  transactionIdentifier:(NSString *)transactionIdentifier
						receipt:(NSData *)receipt
						  price:(NSString *)price
				   currencyCode:(NSString *)currencyCode
			   storeCountryCode:(NSString *)storeCountryCode
{
	self = [super init];
	if (!self)
		return nil;
	
	_productIdentifier = productIdentifier;
	_transactionIdentifier = transactionIdentifier;
	_price = price;
	_currencyCode = currencyCode;
	_storeCountryCode = storeCountryCode;
	
	// if on iOS 7, attempt to use the appStoreReceiptURL (if available)
	if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 &&
		[NSBundle instancesRespondToSelector:@selector(appStoreReceiptURL)]) {
		NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
		if (receiptURL) {
			_receipt = [NSData dataWithContentsOfURL:receiptURL];
			if (_receipt.length == 0) // make sure we don't have an empty file...
				_receipt = nil;
		}
	}
	
	if (!_receipt)
		_receipt = receipt;
	
	return self;
}

- (void)completeObjectWithCompletionHandler:(void(^)(BOOL))completionHandler
{
	NSAssert(completionHandler != NULL, @"completionHandler must not be null");
	
	if (_receipt && _price && _currencyCode && _storeCountryCode) {
		completionHandler(YES);
		return;
	}
	
	[YRDProductRequest loadProduct:_productIdentifier completionHandler:^(SKProduct *product) {
		if (product) {
			_price = [product.price stringValue];
			_currencyCode = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
			_storeCountryCode = [product.priceLocale objectForKey:NSLocaleCountryCode];
			
			completionHandler(YES);
		} else {
			YRDError(@"Failed to load product details for productIdentifier: %@", _productIdentifier);
			
			completionHandler(NO);
		}
	}];
}

@end
