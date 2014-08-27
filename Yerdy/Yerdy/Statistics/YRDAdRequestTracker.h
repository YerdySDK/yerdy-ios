//
//  YRDAdRequestTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-05-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Tracks ad requests & fills
//
// To prevent "lopsided" stats from going to the server, the requests/fills for
// this session are not included in -adRequests/-adFills until launch.php has
// been called ('Yerdy' class will call -launchReported)

@interface YRDAdRequestTracker : NSObject

// dictionary mapping 'ad network name' (NSString) -> '# of requests' (NSNumber)
@property (nonatomic, readonly) NSDictionary *adRequests;
// dictionary mapping 'ad network name' (NSString) -> '# of fills' (NSNumber)
@property (nonatomic, readonly) NSDictionary *adFills;


- (void)logAdRequest:(NSString *)adNetworkName;
- (void)logAdFill:(NSString *)adNetworkName;

- (void)launchReported;
- (void)reset;

@end
