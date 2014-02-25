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

#import <CommonCrypto/CommonHMAC.h>


static NSString *PublisherKey, *PublisherSecret;

@interface YRDRequest ()
{
	NSString *_signature;
}
@end


@implementation YRDRequest

+ (void)setPublisherKey:(NSString *)publisherKey
{
	PublisherKey = publisherKey;
}

+ (void)setPublisherSecret:(NSString *)publisherSecret
{
	PublisherSecret = publisherSecret;
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
	
	// -[NSURL URLWithString:relativeToURL:] uses RFC 1808 to resolve relative URLs
	// These assertions help to ensure that URLs will be resolved correctly
	NSAssert([YRDBaseURL hasSuffix:@"/"], @"YRDBaseURL must end with '/'");
	NSAssert(![path hasPrefix:@"/"], @"path must not start with '/'");
	
	NSURL *base = [NSURL URLWithString:YRDBaseURL];
	_URL = [NSURL URLWithString:path relativeToURL:base];
	
	NSMutableDictionary *params = [[self defaultQueryParameters] mutableCopy];
	if (queryParameters)
		[params addEntriesFromDictionary:queryParameters];
	
	_queryParameters = params;
	
	_signature = [self generateSignature];
	
	return self;
}

- (NSURLRequest *)urlRequest
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.fullURL
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:YRDRequestTimeout];
	if (_signature)
		[request setValue:_signature forHTTPHeaderField:@"X-Request-Auth"];
	
	return request;
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

- (NSString *)generateSignature
{
	NSURL *fullURL = self.fullURL;
	
	NSString *path = [fullURL path];
	NSString *query = [fullURL query];
	
	NSString *contents = [path stringByAppendingString:query];
	
	const char *hmacKey = [PublisherSecret UTF8String];
	const char *hmacData = [contents UTF8String];
	char hmac[CC_SHA1_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgSHA1, hmacKey, strlen(hmacKey), hmacData, strlen(hmacData), hmac);
	
	NSData *bytes = [NSData dataWithBytes:hmac length:sizeof(hmac)];
	return [YRDUtil base64String:bytes];
}

@end
