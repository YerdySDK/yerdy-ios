//
//  YRDURLConnection.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRDRequest.h"

typedef void(^YRDURLConnectionCompletionHandler)(id response, NSError *error);


@interface YRDURLConnection : NSObject

+ (instancetype)sendRequest:(YRDRequest *)request 
		  completionHandler:(YRDURLConnectionCompletionHandler)completionHandler;


- (id)initWithRequest:(YRDRequest *)request
	completionHandler:(YRDURLConnectionCompletionHandler)completionHandler;

- (void)send;

@end
