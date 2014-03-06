//
//  Yerdy_Private.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "Yerdy.h"
#import "YRDUserType.h"

@interface Yerdy (Private)

@property (nonatomic, copy) NSString *ABTag;
@property (nonatomic, assign) YRDUserType userType;

@property (nonatomic, readonly) int itemsPurchased;

@end
