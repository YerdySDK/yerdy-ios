//
//  YRDTrackCounterBatcher.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Handles saving up/queueing up a bunch of YRDCounterEvents so that they can
// be submitted at a later time (in a single service call per event name)

@class YRDCounterEvent;


@interface YRDTrackCounterBatcher : NSObject <NSCoding>

+ (YRDTrackCounterBatcher *)loadFromDisk;

- (void)addEvent:(YRDCounterEvent *)event;
- (void)saveToDisk;

@end
