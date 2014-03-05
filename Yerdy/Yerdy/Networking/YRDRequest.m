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
	NSURL *_URL;
	NSDictionary *_queryParameters;
	NSDictionary *_bodyParameters;
	NSString *_signature;
	NSString *_bodySignature;
}
@end


@implementation YRDRequest

@synthesize URL = _URL;
@synthesize queryParameters = _queryParameters;
@synthesize bodyParameters = _bodyParameters;

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
	return [self initWithPath:path queryParameters:queryParameters bodyParameters:nil];
}

- (id)initWithPath:(NSString *)path queryParameters:(NSDictionary *)queryParameters bodyParameters:(NSDictionary *)bodyParameters
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
	_bodyParameters = bodyParameters;
	
	_signature = [self generateSignature];
	if (_bodyParameters)
		_bodySignature = [self generateBodySignature];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (!self)
		return nil;
	
	_URL = [aDecoder decodeObjectForKey:@"URL"];
	_queryParameters = [aDecoder decodeObjectForKey:@"queryParameters"];
	_signature = [aDecoder decodeObjectForKey:@"signature"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if (_URL) [aCoder encodeObject:_URL forKey:@"URL"];
	if (_queryParameters) [aCoder encodeObject:_queryParameters forKey:@"queryParameters"];
	if (_signature) [aCoder encodeObject:_signature forKey:@"signature"];
}


- (NSURLRequest *)urlRequest
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.fullURL
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:YRDRequestTimeout];
	if (_bodyParameters) {
		NSData *body = [self postBodyDataForRequest];
		
		request.HTTPMethod = @"POST";
		request.HTTPBody = body;
		
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)body.length] forHTTPHeaderField:@"Content-Length"];
	}
	
	if (_signature)
		[request setValue:_signature forHTTPHeaderField:@"X-Request-Auth"];
	
	if (_bodySignature)
		[request setValue:_bodySignature forHTTPHeaderField:@"X-Payload-Auth"];
	
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
	
	return [@"?" stringByAppendingString:[self URLEncodeDictionary:_queryParameters]];
}

- (NSData *)postBodyDataForRequest
{
	if (_bodyParameters.count == 0)
		return nil;
	
	NSString *encodedString = [self URLEncodeDictionary:_bodyParameters];
	NSData *data = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
	return data;
}

- (NSString *)generateSignature
{
	NSURL *fullURL = self.fullURL;
	
	NSString *path = [fullURL path];
	NSString *query = [fullURL query];
	
	NSString *contents = [path stringByAppendingString:query];
	
	const char *hmacData = [contents UTF8String];
	return [self generateSignatureForBytes:hmacData length:strlen(hmacData)];
}

- (NSString *)generateBodySignature
{
	NSString *bodyString = [self URLEncodeDictionary:_bodyParameters];
	const char *hmacData = [bodyString UTF8String];
	return [self generateSignatureForBytes:hmacData length:strlen(hmacData)];
}

- (NSString *)generateSignatureForBytes:(const char *)hmacData length:(size_t)length
{
	const char *hmacKey = [PublisherSecret UTF8String];
	char hmac[CC_SHA1_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgSHA1, hmacKey, strlen(hmacKey), hmacData, length, hmac);
	
	NSData *bytes = [NSData dataWithBytes:hmac length:sizeof(hmac)];
	return [YRDUtil base64String:bytes];
}

- (NSString *)URLEncodeDictionary:(NSDictionary *)dictionary
{
	NSMutableArray *pairs = [NSMutableArray array];
	
	NSArray *sortedKeys = [dictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
	for (NSString *key in sortedKeys) {
		NSString *value = YRDToString(dictionary[key]);
		NSString *pair = [NSString stringWithFormat:@"%@=%@",
						  [YRDUtil URLEncode:key],
						  [YRDUtil URLEncode:value]];
		[pairs addObject:pair];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

@end
