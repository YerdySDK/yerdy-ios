//
//  YRDWebViewController.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDViewController.h"

@protocol YRDWebViewControllerDelegate;


@interface YRDWebViewController : YRDViewController

@property (nonatomic, weak) id<YRDWebViewControllerDelegate> delegate;

- (id)initWithWindow:(UIWindow *)window URL:(NSURL *)URL;

- (void)present;

@end


@protocol YRDWebViewControllerDelegate <NSObject>
@optional
- (void)webViewControllerWillPresent:(YRDWebViewController *)webViewController;
- (void)webViewControllerDidPresent:(YRDWebViewController *)webViewController;
- (void)webViewControllerWillDismiss:(YRDWebViewController *)webViewController;
- (void)webViewControllerDidDismiss:(YRDWebViewController *)webViewController;
@end