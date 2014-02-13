//
//  YRDRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDRequest.h"
#import "YRDConstants.h"


@implementation YRDRequest

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
	NSURL *base = [NSURL URLWithString:YRDBaseURL];
	NSURL *URL = [NSURL URLWithString:path relativeToURL:base];
	
	return [self initWithURL:URL];
}



- (NSURLRequest *)urlRequest
{
	return [NSURLRequest requestWithURL:_URL
							cachePolicy:NSURLRequestUseProtocolCachePolicy
						timeoutInterval:YRDRequestTimeout];
}

@end
