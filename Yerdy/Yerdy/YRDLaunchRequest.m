//
//  YRDLaunchRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDLaunchRequest.h"
#import "YRDJSONResponseHandler.h"
#import "YRDLaunchResponse.h"


@implementation YRDLaunchRequest

+ (instancetype)launchRequest
{
	YRDLaunchRequest *request = [[self alloc] initWithPath:@"/launch.php"];
	// TODO: Add appropriate parameters
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDLaunchResponse class]];
	return request;
}

@end
