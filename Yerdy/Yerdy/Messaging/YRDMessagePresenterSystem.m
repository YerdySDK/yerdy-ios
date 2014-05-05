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
	UIAlertView *_alertView;
	BOOL _dismissed;
}
@end


@implementation YRDMessagePresenterSystem

- (void)present
{
	_dismissed = NO;
	
	YRDMessage *message = self.message;
	_alertView = [[UIAlertView alloc] initWithTitle:message.messageTitle
											message:message.messageText
										   delegate:self
								  cancelButtonTitle:nil
								  otherButtonTitles:nil];
	
	if (message.cancelLabel) {
		_alertView.cancelButtonIndex = [_alertView addButtonWithTitle:message.cancelLabel];
	}
	
	if (message.confirmLabel) {
		[_alertView addButtonWithTitle:message.confirmLabel];
	}
	
	[_alertView show];
}

- (void)dealloc
{
	_alertView.delegate = nil;
}

- (void)dismiss
{
	if (!_dismissed) {
		_dismissed = YES;
		[_alertView dismissWithClickedButtonIndex:-1 animated:YES];
	}
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
	[self willPresent];
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
	[self didPresent];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self willDismiss];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self didDismiss];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (_dismissed)
		return;
	_dismissed = YES;
	
	if (alertView.cancelButtonIndex == buttonIndex) {
		[self messageCancelled];
	} else {
		[self messageClicked];
	}
}

@end
