//
//  YRDImageResponseHandler.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-19.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDImageResponseHandler.h"

#import <UIKit/UIKit.h>

@implementation YRDImageResponseHandler

- (id)processResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
	UIImage *image = [UIImage imageWithData:data];
	if (image == nil && error != NULL) {
		*error = [NSError errorWithDomain:NSStringFromClass([self class])
									 code:0 userInfo:@{ NSLocalizedDescriptionKey : @"Failed to create UIImage" }];
	}
	return image;
}

@end
