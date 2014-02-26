//
//  YRDTrackVirtualPurchaseResponse.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRDJSONType.h"

typedef enum YRDTrackVirtualPurchaseResult {
	YRDTrackVirtualPurchaseResultError = 0,
	YRDTrackVirtualPurchaseResultSuccess = 1,
	YRDTrackVirtualPurchaseResultInvalid = 3,
} YRDTrackVirtualPurchaseResult;


@interface YRDTrackVirtualPurchaseResponse : NSObject <YRDJSONType>

@property (nonatomic, assign) YRDTrackVirtualPurchaseResult result;

@end
