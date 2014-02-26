//
//  YRDLaunchResponse.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDJSONType.h"
#import "YRDUserType.h"

@interface YRDLaunchResponse : NSObject <YRDJSONType>

@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) YRDUserType userType;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSDate *timestamp;

@end
