//
//  YRDConversionTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-22.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Handles tracking whether pull messages convert to item or in app purchases

@class YRDMessage;

@interface YRDConversionTracker : NSObject

- (void)didShowMessage:(YRDMessage *)message;

// If the purchase is a conversion, returns the messageId, otherwise returns nil
// Additionally, removes the item/in app so that a second purchase isn't reported
// as a conversion
- (NSString *)checkItemConversion:(NSString *)itemName;
- (NSString *)checkInAppConversion:(NSString *)productIdentifier;

@end
