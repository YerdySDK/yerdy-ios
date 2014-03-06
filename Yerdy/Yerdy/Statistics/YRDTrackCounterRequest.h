//
//  YRDTrackCounterRequest.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDRequest.h"

@interface YRDTrackCounterRequest : YRDRequest

+ (instancetype)requestWithCounterName:(NSString *)name
								 value:(NSString *)value
							 increment:(int)valueIncrement
							parameters:(NSDictionary *)parameters
				   parameterIncrements:(NSDictionary *)parameterIncrements;

@end
