//
//  YRDItemPurchase.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDItemPurchase.h"
#import "YRDItemPurchase_Private.h"


@implementation YRDItemPurchase

- (id)initWithItem:(NSString *)item
{
	self = [super init];
	if (!self)
		return nil;
	
	_item = item;
	
	return self;
}

@end
