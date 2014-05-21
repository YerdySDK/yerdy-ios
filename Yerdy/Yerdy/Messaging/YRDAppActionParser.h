//
//  YRDAppActionParser.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRDInAppPurchase.h"
#import "YRDItemPurchase.h"

// Parses an app action into something we can use inside the app


typedef enum YRDAppActionType {
	YRDAppActionTypeEmpty, // "do nothing" app action, simply reports click back to server
	YRDAppActionTypeReward,
	YRDAppActionTypeInAppPurchase,
	YRDAppActionTypeItemPurchase,
	YRDAppActionTypeNavigation,
} YRDAppActionType;


@interface YRDAppActionParser : NSObject

// Returns nil on failure
- (id)initWithAppAction:(NSString *)appAction;

@property (nonatomic, readonly) YRDAppActionType actionType;

// Different type based on 'actionType':
//	YRDAppActionTypeEmpty: nil
//	YRDAppActionTypeReward: YRDReward
//	YRDAppActionTypeInAppPurchase: YRDInAppPurchase
//	YRDAppActionTypeItemPurchase: YRDItemPurchase
//	YRDAppActionTypeNavigation: NSString
@property (nonatomic, readonly) id actionInfo;

@end
