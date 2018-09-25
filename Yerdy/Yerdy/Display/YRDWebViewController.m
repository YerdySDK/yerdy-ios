//
//  YRDWebViewController.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDWebViewController.h"
#import "YRDNotificationDispatcher.h"

#import <QuartzCore/QuartzCore.h>

static const CGFloat ToolbarHeight = 44.0;
static const CGFloat IconButtonWidth = 50.0;

static const CFTimeInterval PresentDismissAnimationDuration = 0.2;

static NSString *BackCharacter = @"◄";
static NSString *ForwardCharacter = @"►";

static NSString *AnimatingInKey = @"animatingWebViewIn";
static NSString *AnimatingOutKey = @"animatingWebViewOut";


@interface YRDWebViewController () <UIWebViewDelegate, CAAnimationDelegate>
{
	NSURL *_URL;
	UIWebView *_webView;
	
	UIToolbar *_toolbar;
	
	UIBarButtonItem *_back,
					*_forward,
					*_refresh,
					*_stop;
}
@end

@implementation YRDWebViewController

- (id)initWithWindow:(UIWindow *)window URL:(NSURL *)URL
{
	self = [super initWithWindow:window];
	if (!self)
		return nil;
	
	_URL = URL;
	
	[[YRDNotificationDispatcher sharedDispatcher] addObserver:self selector:@selector(statusBarFrameChanged:)
												 name:UIApplicationDidChangeStatusBarFrameNotification];
	
	return self;
}

- (void)dealloc
{
	[[YRDNotificationDispatcher sharedDispatcher] removeObserver:self];
}

- (void)loadView
{
	[super loadView];
	
	CGRect viewBounds = self.view.bounds;
	
	_toolbar = [[UIToolbar alloc] init];
	_toolbar.translucent = NO;
	_toolbar.frame = CGRectMake(0.0, viewBounds.size.height - ToolbarHeight, viewBounds.size.width, ToolbarHeight);
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[self.view addSubview:_toolbar];
	
	[self setupToolbarItems];
		
	_webView = [[UIWebView alloc] init];
	_webView.delegate = self;
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_webView];
	
	[self setWebViewFrame];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[_webView loadRequest:[NSURLRequest requestWithURL:_URL]];
}

- (void)present
{
	[self addToWindow];
	
	CALayer *layer = self.view.layer;
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	animation.duration = 0.2;
	animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.5, -0.5)];
	animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)];
	
	animation.delegate = self;
	[animation setValue:@YES forKey:AnimatingInKey];
	
	[layer addAnimation:animation forKey:nil];
}

- (void)setWebViewFrame
{
	CGRect viewBounds = self.view.bounds;
	CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
	// the "height" may be width or height, depending on if we are in portrait/landscape
	CGFloat statusBarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);

	_webView.frame = CGRectMake(0.0, statusBarHeight, viewBounds.size.width, viewBounds.size.height - ToolbarHeight - statusBarHeight);
}

- (void)statusBarFrameChanged:(NSNotification *)notification
{
	if (self.isViewLoaded)
		[self setWebViewFrame];
}

#pragma mark - Toolbar items

- (void)setupToolbarItems
{
	_back = [[UIBarButtonItem alloc] initWithImage:[self backNavigationImage]
											 style:UIBarButtonItemStylePlain
											target:self
											action:@selector(back)];
	
	_forward = [[UIBarButtonItem alloc] initWithImage:[self forwardNavigationImage]
												style:UIBarButtonItemStylePlain
											   target:self
											   action:@selector(forward)];
	
	UIBarButtonItem *refreshLeftPadding = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																						target:nil
																						action:NULL];
	refreshLeftPadding.width = 18;
	
	_refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
															 target:self
															 action:@selector(refresh)];
	
	_stop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
														  target:self
														  action:@selector(stop)];
	
	_back.width = _forward.width = IconButtonWidth;
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				   target:nil
																				   action:NULL];
	
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																		  target:self
																		  action:@selector(done)];
	
	_toolbar.items = @[ _back, _forward, refreshLeftPadding, _refresh, flexibleSpace, done ];
}

- (UIImage *)backNavigationImage
{
	static UIImage *image = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		image = [self createFowardImageFlipped:YES];
	});
	return image;
}

- (UIImage *)forwardNavigationImage
{
	static UIImage *image = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		image = [self createFowardImageFlipped:NO];
	});
	return image;
}

- (UIImage *)createFowardImageFlipped:(BOOL)flipped
{
	CGSize size = CGSizeMake(24.0, 24.0);
	CGFloat horizontalPadding = 4.0;
	CGFloat topPadding = 4.0;
	
	UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
	
	UIBezierPath *arrow = [UIBezierPath bezierPath];
	// top left
	[arrow moveToPoint:CGPointMake(horizontalPadding, topPadding)];
	// mid right
	[arrow addLineToPoint:CGPointMake(size.width - topPadding, size.height/2.0 + topPadding/2.0)];
	// bottom left
	[arrow addLineToPoint:CGPointMake(horizontalPadding, size.height)];
	[arrow closePath];
	
	if (flipped) {
		CGAffineTransform transform = CGAffineTransformMakeScale(-1.0, 1.0);
		transform = CGAffineTransformTranslate(transform, -size.width, 0.0);
		[arrow applyTransform:transform];
	}
	
	[[UIColor whiteColor] setFill];
	[arrow fill];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsPopContext();
	
	return image;
}

- (void)updateToolbarState
{
	BOOL loading = _webView.isLoading;
	if (loading) {
		_back.enabled = _forward.enabled = NO;
		
		NSMutableArray *items = [_toolbar.items mutableCopy];
		NSUInteger index = [items indexOfObject:_refresh];
		if (index != NSNotFound) [items replaceObjectAtIndex:index withObject:_stop];
		[_toolbar setItems:items animated:YES];
	} else {
		_back.enabled = [_webView canGoBack];
		_forward.enabled = [_webView canGoForward];
		
		NSMutableArray *items = [_toolbar.items mutableCopy];
		NSUInteger index = [items indexOfObject:_stop];
		if (index != NSNotFound) [items replaceObjectAtIndex:index withObject:_refresh];
		[_toolbar setItems:items animated:YES];
	}
}

#pragma mark - Actions

- (void)back
{
	[_webView goBack];
}

- (void)forward
{
	[_webView goForward];
}

- (void)stop
{
	[_webView stopLoading];
	[self updateToolbarState];
}

- (void)refresh
{
	[_webView reload];
}

- (void)done
{
	CALayer *layer = self.view.layer;
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.duration = PresentDismissAnimationDuration;
	animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)];
	animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5, -0.5)];
	
	animation.delegate = self;
	[animation setValue:@YES forKey:AnimatingOutKey];
	
	[layer addAnimation:animation forKey:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self updateToolbarState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self updateToolbarState];
}

#pragma mark - CAAnimation delegate

- (void)animationDidStart:(CAAnimation *)anim
{
	if ([anim valueForKey:AnimatingInKey] != nil) {
		if ([_delegate respondsToSelector:@selector(webViewControllerWillPresent:)]) {
			[_delegate webViewControllerWillPresent:self];
		}
	} else if ([anim valueForKey:AnimatingOutKey] != nil) {
		if ([_delegate respondsToSelector:@selector(webViewControllerWillDismiss:)]) {
			[_delegate webViewControllerWillDismiss:self];
		}
	}
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	if ([anim valueForKey:AnimatingInKey] != nil) {
		if ([_delegate respondsToSelector:@selector(webViewControllerDidPresent:)]) {
			[_delegate webViewControllerDidPresent:self];
		}
	} else if ([anim valueForKey:AnimatingOutKey] != nil) {
		if ([_delegate respondsToSelector:@selector(webViewControllerDidDismiss:)]) {
			[_delegate webViewControllerDidDismiss:self];
		}
		[self removeFromWindow];
	}
}

@end
