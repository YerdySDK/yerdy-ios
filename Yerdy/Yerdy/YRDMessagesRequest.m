//
//  YRDMessagesRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessagesRequest.h"
#import "YRDJSONResponseHandler.h"
#import "YRDMessage.h"

@implementation YRDMessagesRequest

+ (instancetype)messagesRequest
{
	YRDMessagesRequest *request = [[self alloc] initWithPath:@"/messages.php"];
	// TODO: Add appropriate parameters
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithArrayOfObjectType:[YRDMessage class]];
	return request;
}

@end
