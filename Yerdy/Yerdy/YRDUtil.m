//
//  YRDUtil.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDUtil.h"
#import "YRDConstants.h"
#import <UIKit/UIKit.h>

#if !YRD_COMPILING_FOR_IOS_7

// -[NSData base64Encoding] has existed since iOS 4, but was only publicly
// introduced in iOS 7.  As per Apple docs, it is fine to use on iOS 4+.  See:
// https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSData_Class/DeprecationAppendix/AppendixADeprecatedAPI.html#//apple_ref/occ/instm/NSData/initWithBase64Encoding:

@interface NSData (PreventWarnings)
- (NSString *)base64Encoding;
@end

#endif


static NSString *BundleVersionKey = @"CFBundleVersion";
static NSString *BundleShortVersionKey = @"CFBundleShortVersionString";

static NSString *PlatformSuffix = @"iOS";

static NSString *URLCharactersToEscape = @"￼=,!$&'()*+;?\n\"<>#\t :/";


@implementation YRDUtil

+ (NSString *)deviceIdentifier
{
	// try for IDFV
	if ([UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
		NSUUID *idfv = [UIDevice currentDevice].identifierForVendor;
		if (idfv)
			return idfv.UUIDString;
	}
	
	// fallback on custom ID
	NSString *customID = [[NSUserDefaults standardUserDefaults] stringForKey:YRDCustomDeviceIDDefaultsKey];
	if (!customID) {
		CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
		customID = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
		CFRelease(uuid);
		
		[[NSUserDefaults standardUserDefaults] setObject:customID forKey:YRDCustomDeviceIDDefaultsKey];
	}
	return customID;
}

+ (NSString *)appBundleIdentifierAndPlatform
{
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	return [NSString stringWithFormat:@"%@.%@", bundleIdentifier, PlatformSuffix];
}

+ (NSString *)appVersion
{
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	
	// return the -description of the values in case someone accidentally uses
	// an NSNumber in the Info.plist
	if (infoDictionary[BundleShortVersionKey]) {
		return [infoDictionary[BundleShortVersionKey] description];
	} else if (infoDictionary[BundleVersionKey]) {
		return [infoDictionary[BundleVersionKey] description];
	} else {
		NSLog(@"[Yerdy] WARNING: No app version set in Info.plist.  ");
		NSLog(@"[Yerdy] Please add CFBundleVersion or CFBundleShortVersionString to your Info.plist!");
		
		return @"0.0.0";
	}
}

+ (NSString *)base64String:(NSData *)data
{
#if YRD_COMPILING_FOR_IOS_7
	if ([data respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
		// iOS 7+
		return [data base64EncodedStringWithOptions:0];
	} else {
		// iOS 4-6
		return [data base64Encoding];
	}
#else
	return [data base64Encoding];
#endif
}

+ (NSString *)URLEncode:(NSString *)string
{
	CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(
		kCFAllocatorDefault,
		(__bridge CFStringRef)string,
		NULL,
		(__bridge CFStringRef)URLCharactersToEscape,
		kCFStringEncodingUTF8);
	return CFBridgingRelease(escaped);
}


@end

NSString *YRDToString(id object)
{
	NSString *descrip = [object description];
	return descrip != nil ? descrip : @"";
}
