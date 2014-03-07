//
//  YRDTrackCounterRequest.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDRequest.h"
#import "YRDCounterEvent.h"

@interface YRDTrackCounterRequest : YRDRequest

+ (instancetype)requestWithCounterEvent:(YRDCounterEvent *)event;

// Each event MUST have the same name & type
+ (instancetype)requestWithCounterEvents:(NSArray *)events;

@end
