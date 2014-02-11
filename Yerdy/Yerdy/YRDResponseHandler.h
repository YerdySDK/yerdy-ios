//
//  YRDResponseHandler.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRDResponseHandler : NSObject

- (id)processResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error;

@end
