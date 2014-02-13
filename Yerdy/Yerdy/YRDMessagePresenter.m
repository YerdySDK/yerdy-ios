//
//  YRDMessagePresenter.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessagePresenter.h"
#import "YRDLog.h"
#import "YRDMessagePresenterSystem.h"
#import "YRDMessage.h"
#import "YRDURLConnection.h"


@implementation YRDMessagePresenter

+ (YRDMessagePresenter *)presenterForMessage:(YRDMessage *)message
{
	if (message.style == YRDMessageStyleSystem)
		return [[YRDMessagePresenterSystem alloc] initWithMessage:message];
	else
		return nil; // TODO: Support all message styles
}

- (id)initWithMessage:(YRDMessage *)message
{
	self = [super init];
	if (!self)
		return nil;
	
	_message = message;
	
	return self;
}

- (void)presentInView:(UIView *)view
{
	[NSException raise:NSInternalInconsistencyException
				format:@"-[%@ %@] not implemented", [self class], NSStringFromSelector(_cmd)];
}

- (void)messageClicked
{
	[self reportOutcomeToURL:_message.clickURL];
}

- (void)messageCancelled
{
	[self reportOutcomeToURL:_message.viewURL];
}


- (void)reportOutcomeToURL:(NSURL *)URL
{
	YRDRequest *request = [[YRDRequest alloc] initWithURL:URL];
	[YRDURLConnection sendRequest:request completionHandler:^(id response, NSError *error) {
		if (error)
			YRDError(@"Failed to report message outcome to '%@': %@", request.URL, error);
	}];
}

@end
