//
//  YRDUtil.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YRDDefines.h"

@interface YRDUtil : NSObject

// iOS 6+ - IDFV
// iOS 5 - generated GUID
+ (NSString *)deviceIdentifier;

// Bundle identifier with platform append (for example, org.example.Example.iOS)
+ (NSString *)appBundleIdentifierAndPlatform;
+ (NSString *)appVersion;

+ (NSString *)base64String:(NSData *)data;

+ (NSString *)URLEncode:(NSString *)string;

+ (UIColor *)colorFromHexString:(NSString *)hex;

// If context is specified, prints out a warning to the console when input has some
// invalid characters
+ (NSString *)sanitizeParamKey:(NSString *)input context:(NSString *)context;

@end

// Converts object to a string by sending it the -description message.  If object
// is nil, returns an empty string (@"").
YRD_EXTERN NSString *YRDToString(id object);
