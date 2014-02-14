//
//  YRDDelayedBlock.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Wraps dispatch_after() with additional functionality
// This class is NOT thread safe, use only on the main thread!

@interface YRDDelayedBlock : NSObject

// Schedules a block to be run after 'timeInterval' seconds
+ (instancetype)afterDelay:(NSTimeInterval)timeInterval runBlock:(void(^)(void))block;

// Cancels the scheduled block
- (void)cancel;

// Calls the block now and cancels the scheduled GCD block
- (void)callNow;

@end
