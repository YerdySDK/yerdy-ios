//
//  YRDItemPurchase.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Contains information about an in-game item purchase coming from a message
 
 @see YerdyMessageDelegate
 */
@interface YRDItemPurchase : NSObject

/** The name of item
 
 */
@property (nonatomic, readonly) NSString *item;

@end
