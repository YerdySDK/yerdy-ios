//
//  YRDMessage.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDJSONType.h"
#import <UIKit/UIKit.h>


typedef enum YRDMessageStyle {
	YRDMessageStyleSystem,	// system (UIAlertView) dialog
	YRDMessageStyleImage,	// Image + text + buttons
	YRDMessageStyleLong,	// long text + buttons
} YRDMessageStyle;

typedef enum YRDMessageActionType {
	YRDMessageActionTypeExternalBrowser = 0,
	YRDMessageActionTypeInternalBrowser = 1,
	YRDMessageActionTypeApp = 2,
} YRDMessageActionType;


@interface YRDMessage : NSObject <YRDJSONType>

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, assign) YRDMessageStyle style;
@property (nonatomic, strong) NSString *placement;

@property (nonatomic, strong) NSString *messageTitle;
@property (nonatomic, strong) NSString *messageText;

@property (nonatomic, strong) NSURL *image;

@property (nonatomic, strong) NSDate *expiryDate;

@property (nonatomic, strong) NSString *confirmLabel;
@property (nonatomic, strong) NSString *cancelLabel;

@property (nonatomic, strong) NSURL *clickURL;
@property (nonatomic, strong) NSURL *viewURL;

@property (nonatomic, assign) YRDMessageActionType actionType;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, assign) BOOL forceAction;  // TODO: Implement forceAction

// Style parameters
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *confirmBackgroundColor;
@property (nonatomic, strong) UIColor *cancelBackgroundColor;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *titleTextColor;
@property (nonatomic, strong) UIColor *confirmTextColor;
@property (nonatomic, strong) UIColor *cancelTextColor;
@property (nonatomic, strong) UIColor *expiryTextColor;

// TODO: Implement click messages
// TODO: Implement expiry date
// TODO: Implement message style

@end
