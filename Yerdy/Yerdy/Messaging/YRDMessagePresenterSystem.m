//
//  YRDMessagePresenterSystem.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessagePresenterSystem.h"
#import "YRDMessage.h"

#import <UIKit/UIKit.h>


@interface YRDMessagePresenterSystem () <UIAlertViewDelegate>
{
    UIAlertController *_alertView;
}
@end


@implementation YRDMessagePresenterSystem

- (void)present
{
	//_dismissed = NO;
	
	YRDMessage *message = self.message;
	/*_alertView = [[UIAlertView alloc] initWithTitle:message.messageTitle
											message:message.messageText
										   delegate:self
								  cancelButtonTitle:nil
								  otherButtonTitles:nil];*/
    
    _alertView = [UIAlertController alertControllerWithTitle:message.messageTitle message:message.messageText preferredStyle:UIAlertControllerStyleAlert];
    
	if (message.cancelLabel) {
        [_alertView addAction:[UIAlertAction actionWithTitle:message.cancelLabel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self willDismiss];
            [self messageCancelled];
            [self didDismiss];
        }]];
	}
	
    if (message.confirmLabel) {
        [_alertView addAction:[UIAlertAction actionWithTitle:message.confirmLabel style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self willDismiss];
            [self messageClicked];
            [self didDismiss];
        }]];
    }
    [self willPresent];
	//[_alertView show];
    
    UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    alertWindow.rootViewController = [[UIViewController alloc] init];
    
    // we inherit the main window's tintColor
    alertWindow.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    // window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    alertWindow.windowLevel = topWindow.windowLevel + 1;
    
    [alertWindow makeKeyAndVisible];
    [alertWindow.rootViewController presentViewController:_alertView animated:YES completion:nil];
    
    
    [self didPresent];
}

- (void)dismiss
{}




@end
