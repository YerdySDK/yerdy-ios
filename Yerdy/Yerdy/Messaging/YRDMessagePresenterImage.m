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

- (void)messageViewControllerWillPresent:(YRDMessageViewController *)viewController
{
	[self willPresent];
}

- (void)messageViewControllerDidPresent:(YRDMessageViewController *)viewController
{
	[self didPresent];
}

- (void)messageViewControllerTappedConfirm:(YRDMessageViewController *)viewController
{
	[self messageClicked];
	[_viewController dismiss];
}

- (void)messageViewControllerTappedCancel:(YRDMessageViewController *)viewController
{
	[self messageCancelled];
	[_viewController dismiss];
}

- (void)messageViewControllerWillDismiss:(YRDMessageViewController *)viewController
{
	[self willDismiss];
}

- (void)messageViewControllerDidDismiss:(YRDMessageViewController *)viewController
{
	[self didDismiss];
}

@end
