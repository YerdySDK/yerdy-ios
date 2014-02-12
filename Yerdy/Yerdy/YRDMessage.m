//
//  YRDMessage.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessage.h"
#import "YRDLog.h"


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
		
		@"confirm_label" : @"confirmLabel",
		@"cancel_label" : @"cancelLabel",
		
		@"click" : @"clickURL",
		@"view" : @"viewURL",
		
		@"action_type" : @"actionType",
		@"action" : @"action",
		@"force_action" : @"forceAction"
	};
}

+ (NSDictionary *)jsonTypeConversions
{
	id(^convertURL)(id) = ^(id input) {
		return [NSURL URLWithString:[input description]];
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
		
	};
}

@end
