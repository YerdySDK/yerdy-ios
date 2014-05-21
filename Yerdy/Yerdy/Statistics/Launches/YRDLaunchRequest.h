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
						  screenVisits:(NSDictionary *)screenVisits
							adRequests:(NSDictionary *)adRequests
							   adFills:(NSDictionary *)adFills;

+ (instancetype)launchRequestWithToken:(NSData *)token
							  launches:(NSInteger)launches
							   crashes:(NSInteger)crashes
							  playtime:(NSTimeInterval)playtime
							  currency:(NSArray *)currency
						  screenVisits:(NSDictionary *)screenVisits
							adRequests:(NSDictionary *)adRequests
							   adFills:(NSDictionary *)adFills
							   refresh:(BOOL)refresh;

@end
