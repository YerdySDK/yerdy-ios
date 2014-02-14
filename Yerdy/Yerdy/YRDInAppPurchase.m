//
//  YRDInAppPurchase.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDInAppPurchase.h"
#import "YRDInAppPurchase_Private.h"
#import "YRDMessagePresenter.h"

@interface YRDInAppPurchase ()
{
	YRDMessagePresenter *_messagePresenter;
}
@end


@implementation YRDInAppPurchase

- (id)initWithMessagePresenter:(YRDMessagePresenter *)messagePresenter productIdentifier:(NSString *)productIdentifier
{
	self = [super init];
	if (!self)
		return nil;
	
	_messagePresenter = messagePresenter;
	_productIdentifier = productIdentifier;
	
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
