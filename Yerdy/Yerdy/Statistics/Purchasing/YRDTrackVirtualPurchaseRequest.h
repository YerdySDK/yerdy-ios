//
//  YRDTrackVirtualPurchaseRequest.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDRequest.h"

@interface YRDTrackVirtualPurchaseRequest : YRDRequest

+ (instancetype)requestWithItem:(NSString *)item price:(NSArray *)currencies firstPurchase:(BOOL)firstPurchase;

@end
