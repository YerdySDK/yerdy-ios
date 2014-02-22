//
//  YRDConversionTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-22.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDConversionTracker.h"
#import "YRDAppActionParser.h"
#import "YRDMessage.h"


@interface YRDConversionTracker ()
{
	NSMutableDictionary *_itemToMessageId;
	NSMutableDictionary *_productIdentifierToMessageId;
}
@end


@implementation YRDConversionTracker

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_itemToMessageId = [NSMutableDictionary dictionary];
	_productIdentifierToMessageId = [NSMutableDictionary dictionary];
	
	return self;
}

- (void)didShowMessage:(YRDMessage *)message
{
	if (message.actionType != YRDMessageActionTypeApp)
		return;
	
	YRDAppActionParser *appAction = [[YRDAppActionParser alloc] initWithAppAction:message.action];
	if (appAction.actionType == YRDAppActionTypeInAppPurchase) {
		YRDInAppPurchase *purchase = appAction.actionInfo;
		_productIdentifierToMessageId[purchase.productIdentifier] = message.messageId;
	} else if (appAction.actionType == YRDAppActionTypeItemPurchase) {
		YRDItemPurchase *purchase = appAction.actionInfo;
		_itemToMessageId[purchase.item] = message.messageId;
	}
}

- (NSString *)checkInAppConversion:(NSString *)productIdentifier
{
	NSString *messageId = _productIdentifierToMessageId[productIdentifier];
	if (messageId != nil) {
		[_productIdentifierToMessageId removeObjectForKey:productIdentifier];
	}
	return messageId;
}

- (NSString *)checkItemConversion:(NSString *)itemName
{
	NSString *messageId = _itemToMessageId[itemName];
	if (messageId != nil) {
		[_itemToMessageId removeObjectForKey:itemName];
	}
	return messageId;
}

@end
