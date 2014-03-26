//
//  YRDInAppPurchase.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Contains information about an in-app purchase coming from a message
 
 @see YerdyMessageDelegate
 */
@interface YRDInAppPurchase : NSObject

/** The in-app purchase's product identifier
 
 */
@property (nonatomic, readonly) NSString *productIdentifier;

@end
