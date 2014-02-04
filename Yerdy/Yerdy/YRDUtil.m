//
//  YRDUtil.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDUtil.h"

static NSString *BundleVersionKey = @"CFBundleVersion";
static NSString *BundleShortVersionKey = @"CFBundleShortVersionString";


@implementation YRDUtil

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

@end
