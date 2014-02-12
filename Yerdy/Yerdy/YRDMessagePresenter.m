//
//  YRDMessagePresenter.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessagePresenter.h"
#import "YRDMessagePresenterSystem.h"
#import "YRDMessage.h"


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

@end
