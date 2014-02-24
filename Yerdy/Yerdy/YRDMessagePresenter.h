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
@protocol YRDMessagePresenterDelegate;


@interface YRDMessagePresenter : NSObject

+ (YRDMessagePresenter *)presenterForMessage:(YRDMessage *)message window:(UIWindow *)window;

- (id)initWithMessage:(YRDMessage *)message window:(UIWindow *)window;

@property (nonatomic, weak) id<YRDMessagePresenterDelegate> delegate;
@property (nonatomic, readonly) YRDMessage *message;
@property (nonatomic, readonly) UIWindow *window;

// Subclasses must implement the following methods:
- (void)present;


// Subclasses MUST call the following methods at appropriate times (in the following order)

// 1) Presenting callbacks
- (void)willPresent;	// right before the message is presented
- (void)didPresent;		// right after the message is fully presented (after animations)

// 2) Click callbacks
- (void)messageClicked;		// on message click
- (void)messageCancelled;	// on message cancel

// 3) Dismiss callbacks
- (void)willDismiss;	// right before the message is dismissed
- (void)didDismiss;		// right after the message is fully dismissed (after animations)

@end


@protocol YRDMessagePresenterDelegate <NSObject>
@required

- (void)messagePresenterWillPresentMessage:(YRDMessage *)message;
- (void)messagePresenterDidPresentMessage:(YRDMessage *)message;

// If the user clicked through and an action needs to be taken, 'action' will be non-nil.
// If the action is an internal/external browser, actionParameter is a NSURL. For app actions
// actionParameter will be a YRDAppActionParser
- (void)messagePresenterWillDismissMessage:(YRDMessage *)message withAction:(NSNumber *)action parameter:(id)actionParameter;
- (void)messagePresenterDidDismissMessage:(YRDMessage *)message withAction:(NSNumber *)action parameter:(id)actionParameter;

@end