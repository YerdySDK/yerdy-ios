//
//  YRDWebViewController.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDWebViewController.h"

static const CGFloat ToolbarHeight = 44.0;
static const CGFloat IconButtonWidth = 50.0;

static NSString *BackCharacter = @"◄";
static NSString *ForwardCharacter = @"►";

@interface YRDWebViewController () <UIWebViewDelegate>
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
	
	return self;
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
	_webView.frame = CGRectMake(0.0, 0.0, viewBounds.size.width, viewBounds.size.height - ToolbarHeight);
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_webView];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[_webView loadRequest:[NSURLRequest requestWithURL:_URL]];
}

- (void)present
{
	[self addToWindow];
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
	[self removeFromWindow];
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

@end
