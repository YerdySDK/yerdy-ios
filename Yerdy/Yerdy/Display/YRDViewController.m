//
//  YRDViewController.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDViewController.h"
#import "YRDViewControllerManager.h"

@interface YRDViewController ()
{
	UIWindow *_window;
	UIInterfaceOrientation _orientation;
}
@end

@implementation YRDViewController

- (id)initWithWindow:(UIWindow *)window
{
	self = [super init];
	if (!self)
		return nil;
	
	_window = window;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged)
												 name:UIDeviceOrientationDidChangeNotification object:nil];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
	if (!self.isViewLoaded) {
		self.view = [[UIView alloc] init];
		self.view.backgroundColor = [UIColor clearColor];
	}
	[self sizeViewToScreen];
}

- (void)orientationChanged
{
	UIApplication *app = [UIApplication sharedApplication];
	UIInterfaceOrientation newOrientation = app.statusBarOrientation;
	
	if (_orientation != newOrientation) {
		NSTimeInterval animationDuration = app.statusBarOrientationAnimationDuration;
		[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
			[self sizeViewToScreen];
		} completion:NULL];
	}
}

- (void)sizeViewToScreen
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = [_window bounds];
	
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			break;
		
		case UIInterfaceOrientationPortraitUpsideDown:
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIInterfaceOrientationLandscapeLeft: {
			transform = CGAffineTransformRotate(transform, -0.5 * M_PI);
			CGFloat w = bounds.size.width,
					h = bounds.size.height;
			bounds.size.width = h;
			bounds.size.height = w;
		} break;
			
		case UIInterfaceOrientationLandscapeRight: {
			transform = CGAffineTransformRotate(transform, 0.5 * M_PI);
			CGFloat w = bounds.size.width,
					h = bounds.size.height;
			bounds.size.width = h;
			bounds.size.height = w;
		} break;
	}
		
	CGPoint center = CGPointMake(CGRectGetMidX([_window bounds]), CGRectGetMidY([_window bounds]));
	
	self.view.bounds = bounds;
	self.view.center = center;
	self.view.transform = transform;
	
	_orientation = orientation;
}

- (void)addToWindow
{
	if (self.view.window == _window)
		return;
	
	[YRDViewControllerManager addVisibleViewController:self];
	
	[self sizeViewToScreen];
	[_window addSubview:self.view];
}

- (void)removeFromWindow
{
	[self.view removeFromSuperview];
	[YRDViewControllerManager removeVisibleViewController:self];
}

@end
