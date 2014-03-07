//
//  YRDIgnoreResponseHandler.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-07.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDIgnoreResponseHandler.h"

@implementation YRDIgnoreResponseHandler

- (id)processResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
	return @YES;
}

@end
