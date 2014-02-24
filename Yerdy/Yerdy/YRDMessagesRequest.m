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
#import "YRDUtil.h"

#import "Yerdy_Private.h"


@implementation YRDMessagesRequest

+ (instancetype)messagesRequest
{
	YRDMessagesRequest *request = [[self alloc] initWithPath:@"app_messages/message.php" queryParameters:[self queryParameters]];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithArrayOfObjectType:[YRDMessage class] rootKey:@"message"];
	return request;
}

+ (NSDictionary *)queryParameters
{
	return @{
		@"view" : @0,
		@"tag" : YRDToString([Yerdy sharedYerdy].ABTag),
		@"api" : @2
	};
}

@end
