//
//  YRDTrackCounterResponse.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRDJSONType.h"


typedef enum YRDTrackCounterResult {
	YRDTrackCounterResultSuccess = 0,
	YRDTrackCounterResultFailure = 1, // missing or invalid device, app, counter, counter parameter or server error
} YRDTrackCounterResult;


@interface YRDTrackCounterResponse : NSObject <YRDJSONType>

@property (nonatomic, assign) YRDTrackCounterResult result;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSDate *expirationDate;

@end
