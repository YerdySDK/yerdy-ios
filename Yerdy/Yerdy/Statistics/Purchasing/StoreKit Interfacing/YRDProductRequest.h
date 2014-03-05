//
//  YRDProductRequest.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-04.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface YRDProductRequest : NSObject

+ (void)loadProduct:(NSString *)productIdentifier completionHandler:(void(^)(SKProduct *))completionHandler;

@end
