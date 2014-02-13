//
//  YRDWebViewController.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDWebViewController.h"

@interface YRDWebViewController ()
{
	NSURL *_URL;
	UIWebView *_webView;
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
	
	_webView = [[UIWebView alloc] init];
	_webView.frame = self.view.bounds;
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

@end
