//
//  YRDItemPurchase.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDItemPurchase.h"
#import "YRDItemPurchase_Private.h"
#import "YRDMessagePresenter.h"


@interface YRDItemPurchase ()
{
	YRDMessagePresenter *_messagePresenter;
}
@end


@implementation YRDItemPurchase

- (id)initWithMessagePresenter:(YRDMessagePresenter *)messagePresenter item:(NSString *)item
{
	self = [super init];
	if (!self)
		return nil;
	
	_messagePresenter = messagePresenter;
	_item = item;
	
	return self;
}

- (void)reportSuccess
{
	[_messagePresenter reportAppActionSuccess];
}

- (void)reportFailure
{
	[_messagePresenter reportAppActionFailure];
}

@end
