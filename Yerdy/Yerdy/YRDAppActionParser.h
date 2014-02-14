//
//  YRDAppActionParser.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Parses an app action into something we can use inside the app


typedef enum YRDAppActionType {
	YRDAppActionTypeReward,
	YRDAppActionTypeInAppPurchase,
	YRDAppActionTypeItemPurchase,
} YRDAppActionType;


@interface YRDAppActionParser : NSObject

// Returns nil on failure
- (id)initWithAppAction:(NSString *)appAction;

@property (nonatomic, readonly) YRDAppActionType actionType;

@end
