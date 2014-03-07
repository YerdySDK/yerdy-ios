//
//  YRDReachability.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-07.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

typedef enum YRDNetworkStatus {
	YRDNetworkNotReachable,
	YRDNetworkReachableViaWWAN,
	YRDNetworkReachableViaWiFi,
} YRDNetworkStatus;


@interface YRDReachability ()
{
	SCNetworkReachabilityRef _reachability;
}

@property (nonatomic, readonly) BOOL reachable;

@end


@implementation YRDReachability

+ (BOOL)internetReachable
{
	static YRDReachability *instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance.reachable;
}

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	_reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
	if (!_reachability)
		return nil;
	
	return self;
}

- (BOOL)reachable
{
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(_reachability, &flags)) {
		YRDNetworkStatus status = [self statusForFlags:flags];
		return status != YRDNetworkNotReachable;
	} else {
		return NO;
	}
}

- (YRDNetworkStatus)statusForFlags:(SCNetworkReachabilityFlags)flags
{
	// Copied almost verbatim from Apple's sample code:
	// https://developer.apple.com/Library/ios/samplecode/Reachability/Introduction/Intro.html#//apple_ref/doc/uid/DTS40007324-Intro-DontLinkElementID_2
	
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return YRDNetworkNotReachable;
    }
	
    YRDNetworkStatus returnValue = YRDNetworkNotReachable;
	
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = YRDNetworkReachableViaWiFi;
    }
	
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
		 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
		
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = YRDNetworkReachableViaWiFi;
        }
    }
	
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = YRDNetworkReachableViaWWAN;
    }
    
    return returnValue;
}

@end
