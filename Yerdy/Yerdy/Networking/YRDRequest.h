//
//  YRDRequest.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRDResponseHandler;


@interface YRDRequest : NSObject <NSCoding>

// Used to sign requests.
+ (void)setPublisherKey:(NSString *)publisherKey;
+ (void)setPublisherSecret:(NSString *)publisherSecret;


@property (nonatomic, strong) YRDResponseHandler *responseHandler;

// URL without query string (unless query string was included in URL passed to -initWithURL)
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSDictionary *queryParameters;

// URL with query string appended
@property (nonatomic, readonly) NSURL *fullURL;

// Creates a request with an absolute URL.  No modifications are made (in terms of
// query string, etc..)
- (id)initWithURL:(NSURL *)URL;

// Creates a request relative to YRDBaseURL.  Default query string parameters
// (publisherid/bundleid/deviceid/v) are automatically added, in addition to any
// additional parameters passed in
- (id)initWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path queryParameters:(NSDictionary *)queryParameters;

- (NSURLRequest *)urlRequest;

@end
