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

- (id)initWithPath:(NSString *)path
{
	self = [super init];
	if (!self)
		return nil;
	
	_path = path;
	
	return self;
}

- (NSURLRequest *)urlRequest
{
	NSURL *base = [NSURL URLWithString:YRDBaseURL];
	NSURL *url = [NSURL URLWithString:_path relativeToURL:base];
	
	return [NSURLRequest requestWithURL:url
							cachePolicy:NSURLRequestUseProtocolCachePolicy
						timeoutInterval:YRDRequestTimeout];
}

@end
