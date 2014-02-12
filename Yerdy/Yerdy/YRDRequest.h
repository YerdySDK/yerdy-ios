//
//  YRDRequest.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRDResponseHandler;


@interface YRDRequest : NSObject

@property (nonatomic, strong) YRDResponseHandler *responseHandler;

// The remote path with a leading slash (for example, @"/launch.php")
@property (nonatomic, strong) NSString *path;

- (id)initWithPath:(NSString *)path;

- (NSURLRequest *)urlRequest;

@end