//
//  YRDMessageViewController.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-18.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessageViewController.h"
#import "YRDMessageView.h"

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

- (IBAction)confirmTapped:(id)sender
{
	[_delegate messageViewControllerFinishedWithConfirm:self];
}

- (IBAction)cancelTapped:(id)sender
{
	[_delegate messageViewControllerFinishedWithCancel:self];
}

@end
