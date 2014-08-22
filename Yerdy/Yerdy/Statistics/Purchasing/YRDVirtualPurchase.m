//
//  YRDVirtualPurchase.m
//  Yerdy
//
//  Created by Darren Clark on 2014-08-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDVirtualPurchase.h"

@implementation YRDVirtualPurchase

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (!self)
		return nil;
	
	_item = [aDecoder decodeObjectForKey:@"item"];
	_currencies = [aDecoder decodeObjectForKey:@"currencies"];
	_onSale = [aDecoder decodeBoolForKey:@"onSale"];
	_firstPurchase = [aDecoder decodeBoolForKey:@"firstPurchase"];
	_purchasesSinceInApp = [aDecoder decodeObjectForKey:@"purchasesSinceInApp"];
	_conversionMessageId = [aDecoder decodeObjectForKey:@"conversionMessageId"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if (_item)
		[aCoder encodeObject:_item forKey:@"item"];
	if (_currencies)
		[aCoder encodeObject:_currencies forKey:@"currencies"];
	
	[aCoder encodeBool:_onSale forKey:@"onSale"];
	[aCoder encodeBool:_firstPurchase forKey:@"firstPurchase"];
	
	if (_purchasesSinceInApp)
		[aCoder encodeObject:_purchasesSinceInApp forKey:@"purchasesSinceInApp"];
	if (_conversionMessageId)
		[aCoder encodeObject:_conversionMessageId forKey:@"conversionMessageId"];
}

@end
