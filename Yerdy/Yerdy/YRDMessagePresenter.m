//
//  YRDMessagePresenter.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessagePresenter.h"
#import "Yerdy.h"
#import "YRDAppActionParser.h"
#import "YRDLog.h"
#import "YRDMessagePresenterImage.h"
#import "YRDMessagePresenterSystem.h"
#import "YRDMessage.h"
#import "YRDURLConnection.h"


// Since we may get released we
#define IMITATE_RETAIN_AUTORELEASE()	id strongSelf__ = self; (void)strongSelf__;


typedef enum YRDMessageOutcome {
	YRDMessageOutcomeNone, // outcome hasn't been determined yet (user hasn't pressed a button)
	YRDMessageOutcomeClick,
	YRDMessageOutcomeCancel,
} YRDMessageOutcome;


@interface YRDMessagePresenter ()
{
	NSNumber *_outcomeAction;
	id _outcomeParameter;
}
@end


@implementation YRDMessagePresenter

+ (YRDMessagePresenter *)presenterForMessage:(YRDMessage *)message window:(UIWindow *)window
{
	if (message.style == YRDMessageStyleSystem)
		return [[YRDMessagePresenterSystem alloc] initWithMessage:message window:window];
	else if (message.style == YRDMessageStyleImage)
		return [[YRDMessagePresenterImage alloc] initWithMessage:message window:window];
	else
		return nil; // TODO: Support all message styles
}

- (id)initWithMessage:(YRDMessage *)message window:(UIWindow *)window
{
	self = [super init];
	if (!self)
		return nil;
	
	_message = message;
	_window = window;
	
	return self;
}

- (void)present
{
	[NSException raise:NSInternalInconsistencyException
				format:@"-[%@ %@] not implemented", [self class], NSStringFromSelector(_cmd)];
}

#pragma mark - Message presented/dismissed

- (void)willPresent
{
	IMITATE_RETAIN_AUTORELEASE()
	[_delegate messagePresenter:self willPresentMessage:_message];
}

- (void)didPresent
{
	IMITATE_RETAIN_AUTORELEASE()
	[_delegate messagePresenter:self didPresentMessage:_message];
}

- (void)willDismiss
{
	IMITATE_RETAIN_AUTORELEASE()
	[_delegate messagePresenter:self willDismissMessage:_message withAction:_outcomeAction parameter:_outcomeParameter];
}

- (void)didDismiss
{
	IMITATE_RETAIN_AUTORELEASE()
	[_delegate messagePresenter:self didDismissMessage:_message withAction:_outcomeAction parameter:_outcomeParameter];
}

#pragma mark - Message click/cancel

- (void)messageClicked
{
	// external/internal browser actions are redirects from the clickURL,
	// so need to report an outcome for them.  We only need to report an
	// outcome on YRDMessageActionTypeApp actions
	if (_message.actionType == YRDMessageActionTypeExternalBrowser ||
		_message.actionType == YRDMessageActionTypeInternalBrowser) {
		_outcomeAction = @(_message.actionType);
		_outcomeParameter = _message.clickURL;
	} else if (_message.actionType == YRDMessageActionTypeApp) {
		[self reportOutcomeToURL:_message.clickURL];
		YRDAppActionParser *parser = [[YRDAppActionParser alloc] initWithAppAction:_message.action];
		if (parser != nil && parser.actionType != YRDAppActionTypeEmpty) {
			_outcomeAction = @(_message.actionType);
			_outcomeParameter = parser;
		}
	}
}

- (void)messageCancelled
{
}

#pragma mark - Handling outcomes

- (void)reportOutcomeToURL:(NSURL *)URL
{
	YRDRequest *request = [[YRDRequest alloc] initWithURL:URL];
	[YRDURLConnection sendRequest:request completionHandler:^(id response, NSError *error) {
		if (error)
			YRDError(@"Failed to report message outcome to '%@': %@", request.URL, error);
	}];
}

@end
