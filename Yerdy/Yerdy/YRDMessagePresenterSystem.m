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
}
@end


@implementation YRDMessagePresenterSystem

- (void)present
{
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.cancelButtonIndex == buttonIndex) {
		[self messageCancelled];
	} else {
		[self messageClicked];
	}
}

@end
