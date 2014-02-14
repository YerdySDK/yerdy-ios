//
//  Yerdy.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YerdyDelegate.h"

@interface Yerdy : NSObject

+ (instancetype)startWithPublisherKey:(NSString *)key;
+ (instancetype)sharedYerdy;

@property (nonatomic, weak) id<YerdyDelegate> delegate;

// Sets or retrieves the users push notification token
@property (nonatomic, copy) NSData *pushToken;

// Is a message available for the passed in placement?
//
// TODO: How to handle nil?
- (BOOL)messageAvailable:(NSString *)placement;

// Show message for placement.
// Equivalent to [yerdy showMessage:placement inWindow:nil]
- (BOOL)showMessage:(NSString *)placement;

// Show message for placement in the specified UIWindow
// If 'window' is nil, defaults to the application's keyWindow
//
// TODO: How to handle nil for 'placement'?
- (BOOL)showMessage:(NSString *)placement inWindow:(UIWindow *)window;

@end
