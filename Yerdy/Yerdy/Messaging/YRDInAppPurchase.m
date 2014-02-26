//
//  YRDInAppPurchase.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDInAppPurchase.h"
#import "YRDInAppPurchase_Private.h"


@implementation YRDInAppPurchase

- (id)initWithProductIdentifier:(NSString *)productIdentifier;
{
	self = [super init];
	if (!self)
		return nil;
	
	_productIdentifier = productIdentifier;
	
	return self;
}

@end
