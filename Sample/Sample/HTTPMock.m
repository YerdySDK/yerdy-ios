//
//  HTTPMock.m
//  Sample
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "HTTPMock.h"

static NSDictionary *URLToFileMapping = nil;


@implementation HTTPMock

+ (void)enableWithPlist:(NSString *)name
{
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
	URLToFileMapping = [NSDictionary dictionaryWithContentsOfFile:path];
	
	[NSURLProtocol registerClass:self];
}

+ (NSString *)filePathForRequest:(NSURLRequest *)request
{
	NSString *fileName = [URLToFileMapping objectForKey:[request.URL absoluteString]];
	if (!fileName && request.URL.query.length > 0) {
		NSString *query = [NSString stringWithFormat:@"?%@", request.URL.query];
		NSString *withoutQuery = [request.URL.absoluteString stringByReplacingOccurrencesOfString:query withString:@""];
		
		fileName = [URLToFileMapping objectForKey:withoutQuery];
	}
	return [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
}

#pragma mark - NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
	return [self filePathForRequest:request] != nil;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
	return request;
}

- (void)startLoading
{
	NSString *filePath = [[self class] filePathForRequest:self.request];
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	
	NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL
														MIMEType:nil
										   expectedContentLength:data.length
												textEncodingName:nil];
	
	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	[self.client URLProtocol:self didLoadData:data];
	[self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
	// Oops..
}


@end
