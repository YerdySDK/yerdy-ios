//
//  YRDReward.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Contains information about a reward coming from a message
 
 @see YerdyMessageDelegate
 */
@interface YRDReward : NSObject

/** A dictionary containing rewards and amounts
 
 For example:
 
	@{
		@"Lives" : @10,
		@"Coins" : @1000
	}
 */
@property (nonatomic, readonly) NSDictionary *rewards;

@end
