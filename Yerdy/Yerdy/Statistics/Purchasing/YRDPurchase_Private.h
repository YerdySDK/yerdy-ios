//
//  YRDPurchase_Private.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-04.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDPurchase.h"

@interface YRDPurchase (Private)

// Fetches missing properties on the object
- (void)completeObjectWithCompletionHandler:(void(^)(BOOL))completionHandler;

@end
