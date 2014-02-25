//
//  YRDMessage.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessage.h"
#import "YRDLog.h"
#import "YRDUtil.h"


@implementation YRDMessage

+ (NSDictionary *)jsonMappings
{
	return @{
		@"id" : @"messageId",
		@"style" : @"style",
		@"placement" : @"placement",
		
		@"message_title" : @"messageTitle",
		@"message_text" : @"messageText",
		
		@"image" : @"image",
		
		@"expire_time" : @"expiryDate",
		
		@"confirm_label" : @"confirmLabel",
		@"cancel_label" : @"cancelLabel",
		
		@"click" : @"clickURL",
		@"view" : @"viewURL",
		
		@"action_type" : @"actionType",
		@"action" : @"action",
		@"force_action" : @"forceAction",
		
		@"text_background" : @"backgroundColor",
		@"confirm_background" : @"confirmBackgroundColor",
		@"cancel_background" : @"cancelBackgroundColor",
		
		@"text_color" : @"textColor",
		@"title_color" : @"titleTextColor",
		@"confirm_color" : @"confirmTextColor",
		@"cancel_color" : @"cancelTextColor",
		@"expiry_color" : @"expiryTextColor",
	};
}

+ (NSDictionary *)jsonTypeConversions
{
	id convertURL = ^(id input) {
		return [NSURL URLWithString:[input description]];
	};
	
	id convertColor = ^id(id input) {
		return [YRDUtil colorFromHexString:[input description]];
	};
	
	return @{
		
		@"style" : ^id(id input) {
			if ([input isEqual:@"image"]) {
				return @(YRDMessageStyleImage);
			} else if ([input isEqual:@"long"]) {
				return @(YRDMessageStyleLong);
			} else {
				// 'short' or 'system'.  For now just default to system
				return @(YRDMessageStyleSystem);
			}
		},

		@"image" : convertURL,
		
		@"expire_time" : ^id(id input) {
			NSTimeInterval timeInterval = [input respondsToSelector:@selector(doubleValue)] ? [input doubleValue] : 0.0;
			if (timeInterval <= 0.0)
				return nil;
			
			return [NSDate dateWithTimeIntervalSince1970:timeInterval];
		},
		
		@"click" : convertURL,
		@"view" : convertURL,

		@"action_type" : ^id(id input) {
			int value = [input intValue];
			// Make sure the server gives us a valid value
			switch ((YRDMessageActionType)value) {
				case YRDMessageActionTypeExternalBrowser:
				case YRDMessageActionTypeInternalBrowser:
				case YRDMessageActionTypeApp:
					return @(value);
			}
			
			YRDError(@"Invalid YRDMessage.actionType value: %d", value);
			// fallback to external browser
			return @(YRDMessageActionTypeExternalBrowser);
		},
		 
		@"force_action" : ^id(id input) {
			return @([input boolValue]);
		},
		
		@"text_background" : convertColor,
		@"confirm_background" : convertColor,
		@"cancel_background" : convertColor,
		
		@"text_color" : convertColor,
		@"title_color" : convertColor,
		@"confirm_color" : convertColor,
		@"cancel_color" : convertColor,
		@"expiry_color" : convertColor,
	};
}

@end
