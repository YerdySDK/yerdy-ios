//
//  YRDVirtualPurchase.h
//  Yerdy
//
//  Created by Darren Clark on 2014-08-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRDVirtualPurchase : NSObject <NSCoding>

@property (nonatomic, strong) NSString *item;
@property (nonatomic, strong) NSArray *currencies;
@property (nonatomic, assign) BOOL onSale;
@property (nonatomic, assign) BOOL firstPurchase;
@property (nonatomic, strong) NSNumber *purchasesSinceInApp;
@property (nonatomic, strong) NSString *conversionMessageId;

@end
