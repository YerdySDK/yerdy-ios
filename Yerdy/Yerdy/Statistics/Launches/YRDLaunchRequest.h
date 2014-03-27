//
//  YRDLaunchRequest.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDRequest.h"

@interface YRDLaunchRequest : YRDRequest

+ (instancetype)launchRequestWithToken:(NSData *)token
							  launches:(NSInteger)launches
							   crashes:(NSInteger)crashes
							  playtime:(NSTimeInterval)playtime
							  currency:(NSArray *)currency
						  screenVisits:(NSDictionary *)screenVisits;

+ (instancetype)launchRequestWithToken:(NSData *)token
							  launches:(NSInteger)launches
							   crashes:(NSInteger)crashes
							  playtime:(NSTimeInterval)playtime
							  currency:(NSArray *)currency
						  screenVisits:(NSDictionary *)screenVisits
							   refresh:(BOOL)refresh;

@end
