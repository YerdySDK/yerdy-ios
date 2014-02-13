//
//  YRDViewController.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDViewController.h"

@interface YRDViewController ()
{
	UIWindow *_window;
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
	self.view = [[UIView alloc] init];
	self.view.backgroundColor = [UIColor clearColor];
	[self sizeViewToScreen];
}

- (void)orientationChanged
{
	[self sizeViewToScreen];
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
			transform = CGAffineTransformRotate(transform, 0.5 * M_PI);
			CGFloat w = bounds.size.width,
					h = bounds.size.height;
			bounds.size.width = h;
			bounds.size.height = w;
		} break;
			
		case UIInterfaceOrientationLandscapeRight: {
			transform = CGAffineTransformRotate(transform, -0.5 * M_PI);
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
}

- (void)addToWindow
{
	if (self.view.window == _window)
		return;
	
	[self sizeViewToScreen];
	[_window addSubview:self.view];
}

- (void)removeFromWindow
{
	[self.view removeFromSuperview];
}

@end
