//
//  YRDMessageViewController.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-18.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessageViewController.h"
#import "YRDMessage.h"
#import "YRDMessageView.h"
#import "YRDImageCache.h"

#import <QuartzCore/QuartzCore.h>

@interface YRDMessageViewController ()
{
	YRDMessage *_message;
}
@end

@implementation YRDMessageViewController

- (id)initWithWindow:(UIWindow *)window message:(YRDMessage *)message
{
	self = [super initWithWindow:window];
	if (!self)
		return nil;
	
	_message = message;
	
	return self;
}

- (void)loadView
{
	self.view = [[YRDMessageView alloc] initWithViewController:self message:_message];
	[super loadView];
}

- (void)viewDidLoad
{
	if (_message.image) {
		__weak UIImageView *weakImageView = _imageView;
		[[YRDImageCache sharedCache] loadImageAtURL:_message.image completionHandler:^(UIImage *image) {
			weakImageView.image = image;
		}];
	}
	
	if (_message.cancelDelay > 0.0) {
		_cancelButton.hidden = YES;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if (_message.cancelDelay > 0.0 && _cancelButton) {
		__weak UIButton *weakCancel = _cancelButton;
		
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_message.cancelDelay * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			weakCancel.hidden = NO;
		});
	} else {
		_cancelButton.hidden = NO;
	}
}

- (void)present
{
	[_delegate messageViewControllerWillPresent:self];
	[self addToWindow];
	
	CALayer *containerLayer = _containerView.layer;
	CATransform3D originalTransform = containerLayer.transform;
	
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = 1.0 / -100;
	transform = CATransform3DScale(transform, 0.9, 0.5, 1.0);
	transform = CATransform3DTranslate(transform, -[UIScreen mainScreen].bounds.size.width * 2.0, 0, 0);
	transform = CATransform3DRotate(transform, -45.0 * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
	containerLayer.transform = transform;
	
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		containerLayer.transform = originalTransform;
		self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
	} completion:^(BOOL completed) {
		[_delegate messageViewControllerDidPresent:self];
	}];
}

- (void)dismiss
{
	[_delegate messageViewControllerWillDismiss:self];
	CALayer *containerLayer = _containerView.layer;
	
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = 1.0 / -100;
	transform = CATransform3DScale(transform, 0.9, 0.5, 1.0);
	transform = CATransform3DTranslate(transform, [UIScreen mainScreen].bounds.size.width * 2.0, 0, 0);
	transform = CATransform3DRotate(transform, 45.0 * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
	
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		containerLayer.transform = transform;
		self.view.backgroundColor = [UIColor clearColor];
	} completion:^(BOOL completed) {
		[self removeFromWindow];
		[_delegate messageViewControllerDidDismiss:self];
	}];
}

- (IBAction)confirmTapped:(id)sender
{
	[_delegate messageViewControllerTappedConfirm:self];
}

- (IBAction)cancelTapped:(id)sender
{
	[_delegate messageViewControllerTappedCancel:self];
}

@end
