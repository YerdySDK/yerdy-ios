//
//  YRDPurchaseSubmitter.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-07.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRDTrackPurchaseRequest;


@interface YRDPurchaseSubmitter : NSObject <NSCoding>

+ (YRDPurchaseSubmitter *)loadFromDisk;

- (void)addRequest:(YRDTrackPurchaseRequest *)request;
- (void)uploadIfNeeded;

@end
