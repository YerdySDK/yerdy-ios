//
//  YRDMessagePresenter.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <UIKit/UIKit.h>

// Handles display of a YRDMessage.
// Different message types are delegated to different YRDMessagePresenter classes.
// Use +presenterForMessage: to create a YRDMessagePresenter capable of displaying
// the given YRDMessage

@class YRDMessage;


@interface YRDMessagePresenter : NSObject

+ (YRDMessagePresenter *)presenterForMessage:(YRDMessage *)message;

- (id)initWithMessage:(YRDMessage *)message;

@property (nonatomic, readonly) YRDMessage *message;


// Subclasses must implement the following methods:
- (void)presentInView:(UIView *)view;

@end
