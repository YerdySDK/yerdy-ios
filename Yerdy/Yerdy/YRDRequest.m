//
//  YRDRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDRequest.h"
#import "YRDConstants.h"
#import "YRDUtil.h"

static NSString *PublisherKey;


@implementation YRDRequest

+ (void)setPublisherKey:(NSString *)publisherKey
{
	PublisherKey = publisherKey;
}


- (id)initWithURL:(NSURL *)URL;
{
	self = [super init];
	if (!self)
		return nil;
	
	_URL = URL;
	
	return self;
}

- (id)initWithPath:(NSString *)path
{
	return [self initWithPath:path queryParameters:nil];
}

- (id)initWithPath:(NSString *)path queryParameters:(NSDictionary *)queryParameters
{
	self = [super init];
	if (!self)
		return nil;
	
	NSURL *base = [NSURL URLWithString:YRDBaseURL];
	_URL = [NSURL URLWithString:path relativeToURL:base];
	
	NSMutableDictionary *params = [[self defaultQueryParameters] mutableCopy];
	if (queryParameters)
		[params addEntriesFromDictionary:queryParameters];
	
	_queryParameters = params;
		
	return self;
}

- (NSURLRequest *)urlRequest
{
	return [NSURLRequest requestWithURL:self.fullURL
							cachePolicy:NSURLRequestUseProtocolCachePolicy
						timeoutInterval:YRDRequestTimeout];
}

- (NSURL *)fullURL
{
	NSString *absoluteString = [_URL absoluteString];
	NSString *withQuery = [absoluteString stringByAppendingString:[self queryStringForRequest]];
	return [NSURL URLWithString:withQuery];
}

- (NSDictionary *)defaultQueryParameters
{
	return @{
		@"publisherid" : YRDToString(PublisherKey),
		@"bundleid" : YRDToString([YRDUtil appBundleIdentifierAndPlatform]),
		@"deviceid" : YRDToString([YRDUtil deviceIdentifier]),
		@"v" : YRDToString([YRDUtil appVersion]),
		@"fmt" : @"json",
	};
}

// Includes '?'
- (NSString *)queryStringForRequest
{
	if (_queryParameters.count == 0)
		return @"";
	
	NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in _queryParameters) {
		NSString *value = YRDToString(_queryParameters[key]);
		NSString *pair = [NSString stringWithFormat:@"%@=%@",
						  [YRDUtil URLEncode:key],
						  [YRDUtil URLEncode:value]];
		[pairs addObject:pair];
	}
	
	return [@"?" stringByAppendingString:[pairs componentsJoinedByString:@"&"]];
}

@end
