//
//  YRDPurchase.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-25.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


@interface YRDPurchase : NSObject

+ (instancetype)purchaseWithTransaction:(SKPaymentTransaction *)transaction;

// TODO: Expose appropriate properties, etc...

@end
