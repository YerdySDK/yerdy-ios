//
//  YRDReward.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRDReward : NSObject

// Maps reward name to amount.  For example:
// @{
//		@"Lives" : @10,
//		@"Coins" : @1000
// }
@property (nonatomic, readonly) NSDictionary *rewards;

@end
