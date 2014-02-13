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

@property (nonatomic, strong) NSURL *URL;

// Creates a request with an absolute URL
- (id)initWithURL:(NSURL *)URL;
// Creates a request relative to YRDBaseURL
- (id)initWithPath:(NSString *)path;

- (NSURLRequest *)urlRequest;

@end
