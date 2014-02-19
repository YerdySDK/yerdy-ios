//
//  YRDMessagePresenterImage.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-18.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessagePresenterImage.h"
#import "YRDMessageViewController.h"

@interface YRDMessagePresenterImage () <YRDMessageViewControllerDelegate>
{
	YRDMessageViewController *_viewController;
}
@end


@implementation YRDMessagePresenterImage

- (void)present
{
	_viewController = [[YRDMessageViewController alloc] initWithWindow:self.window message:self.message];
	_viewController.delegate = self;
	[_viewController present];
}

- (void)messageViewControllerFinishedWithConfirm:(YRDMessageViewController *)viewController
{
	[self messageClicked];
	[_viewController dismiss];
}

- (void)messageViewControllerFinishedWithCancel:(YRDMessageViewController *)viewController
{
	[self messageCancelled];
	[_viewController dismiss];
}

@end
