//
//  YRDViewControllerManager.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Tracks which view controllers are currently visible.
// Mainly used to ensure YRDViewControllers are still alive while being
// presented to the screen

@class YRDViewController;

@interface YRDViewControllerManager : NSObject

+ (void)addVisibleViewController:(YRDViewController *)viewController;
+ (void)removeVisibleViewController:(YRDViewController *)viewController;

@end
