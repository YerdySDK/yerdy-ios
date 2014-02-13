//
//  YRDViewControllerManager.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDViewControllerManager.h"
#import "YRDViewController.h"

@implementation YRDViewControllerManager

// Provides synchronized access to the NSMutableSet containing the active
// view controllers
+ (void)modifyContainer:(void(^)(NSMutableSet*))modifyCallback
{
	@synchronized (self) {
		static NSMutableSet *container;
		if (!container) {
			container = [[NSMutableSet alloc] init];
		}
		modifyCallback(container);
	}
}

+ (void)addVisibleViewController:(YRDViewController *)viewController
{
	[self modifyContainer:^(NSMutableSet *viewControllers) {
		[viewControllers addObject:viewController];
	}];
}

+ (void)removeVisibleViewController:(YRDViewController *)viewController
{
	[self modifyContainer:^(NSMutableSet *viewControllers) {
		[viewControllers removeObject:viewController];
	}];
}

@end
