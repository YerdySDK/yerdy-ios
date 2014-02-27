//
//  YRDTrackPurchaseResponse.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRDJSONType.h"

// Used by both YRDTrackPurchaseRequest & YRDTrackVirtualPurchaseRequest

typedef enum YRDTrackPurchaseResult {
	YRDTrackPurchaseResultServerError = 0,
	YRDTrackPurchaseResultSuccess = 1,
	YRDTrackPurchaseResultInvalid = 2,
	YRDTrackPurchaseResultRequestError = 3,
} YRDTrackPurchaseResult;


@interface YRDTrackPurchaseResponse : NSObject <YRDJSONType>

@property (nonatomic, assign) YRDTrackPurchaseResult result;

@end
