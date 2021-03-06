//
//  YRDRequestCache.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRDRequest;


// Caches requests for the device to send up next time it is online

@interface YRDRequestCache : NSObject

// NOTE: It is possible 'nil' may be returned due to an inability to create
// the cache directory (low memory, incorrect file permissions, etc..).  This
// isn't a *huge* deal, as everything outside this class will still function
// fine
+ (instancetype)sharedCache;


// Stores a request
- (void)storeRequest:(YRDRequest *)request;

- (void)sendStoredRequests;

@end
