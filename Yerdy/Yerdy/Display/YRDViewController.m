//
//  YRDViewController.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDViewController.h"
#import "YRDViewControllerManager.h"
#import "YRDNotificationDispatcher.h"
#import "YRDConstants.h"

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
	
	[[YRDNotificationDispatcher sharedDispatcher] addObserver:self selector:@selector(orientationChanged)
												 name:UIDeviceOrientationDidChangeNotification];
	
	return self;
}

- (void)dealloc
{
	[[YRDNotificationDispatcher sharedDispatcher] removeObserver:self];
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

- (void)adjustTransform:(CGAffineTransform *)transform bounds:(CGRect *)bounds
forInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	NSParameterAssert(transform != nil);
	NSParameterAssert(bounds != nil);
	
	// it appears that this transform logic is no longer needed when
	// compiling for iOS 8 **AND** running on iOS 8
	//
	// (the rotation issue isn't present when building w/ iOS 7 SDK and
	// running on iOS 8)
#ifdef YRD_COMPILING_FOR_IOS_8
	if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
		return;
	}
#endif
	
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			break;
			
		case UIInterfaceOrientationPortraitUpsideDown:
			*transform = CGAffineTransformRotate(*transform, M_PI);
			break;
			
		case UIInterfaceOrientationLandscapeLeft: {
			*transform = CGAffineTransformRotate(*transform, -0.5 * M_PI);
			CGFloat w = bounds->size.width,
					h = bounds->size.height;
			bounds->size.width = h;
			bounds->size.height = w;
		} break;
			
		case UIInterfaceOrientationLandscapeRight: {
			*transform = CGAffineTransformRotate(*transform, 0.5 * M_PI);
			CGFloat w = bounds->size.width,
					h = bounds->size.height;
			bounds->size.width = h;
			bounds->size.height = w;
		} break;
		
#if YRD_COMPILING_FOR_IOS_8
		case UIInterfaceOrientationUnknown:
			break;
#endif
	}
}

- (void)sizeViewToScreen
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = [_window bounds];
	
	[self adjustTransform:&transform bounds:&bounds forInterfaceOrientation:orientation];
		
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
