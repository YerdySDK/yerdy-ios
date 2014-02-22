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
#import "YRDWebViewController.h"


typedef enum YRDMessageOutcome {
	YRDMessageOutcomeNone, // outcome hasn't been determined yet (user hasn't pressed a button)
	YRDMessageOutcomeClick,
	YRDMessageOutcomeCancel,
} YRDMessageOutcome;


@interface YRDMessagePresenter ()
{
	YRDMessageOutcome _outcome;
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
	[_delegate yerdy:_delegate willPresentMessageForPlacement:_message.placement];
}

- (void)didPresent
{
	[_delegate yerdy:_delegate didPresentMessageForPlacement:_message.placement];
}

- (void)willDismiss
{
	[_delegate yerdy:_delegate willDismissMessageForPlacement:_message.placement];
}

- (void)didDismiss
{
	[_delegate yerdy:_delegate didDismissMessageForPlacement:_message.placement];
	[self handleOutcome];
	[_delegate messagePresenterFinished:self];
}

#pragma mark - Message click/cancel

- (void)messageClicked
{
	_outcome = YRDMessageOutcomeClick;
}

- (void)messageCancelled
{
	_outcome = YRDMessageOutcomeCancel;
}

#pragma mark - Handling outcomes

- (void)handleOutcome
{
	if (_outcome == YRDMessageOutcomeClick) {
		// external/internal browser actions are redirects from the clickURL,
		// so need to report an outcome for them.  We only need to report an
		// outcome on YRDMessageActionTypeApp actions
		if (_message.actionType == YRDMessageActionTypeExternalBrowser) {
			[[UIApplication sharedApplication] openURL:_message.clickURL];
		} else if (_message.actionType == YRDMessageActionTypeInternalBrowser) {
			YRDWebViewController *vc = [[YRDWebViewController alloc] initWithWindow:_window
																				URL:_message.clickURL];
			[vc present];
		} else {
			[self reportOutcomeToURL:_message.clickURL];
			YRDAppActionParser *parser = [[YRDAppActionParser alloc] initWithAppAction:_message.action];
			if (parser != nil) {
				switch (parser.actionType) {
					case YRDAppActionTypeInAppPurchase:
						[_delegate yerdy:_delegate handleInAppPurchase:parser.actionInfo];
						break;
						
					case YRDAppActionTypeItemPurchase:
						[_delegate yerdy:_delegate handleItemPurchase:parser.actionInfo];
						break;
						
					case YRDAppActionTypeReward:
						[_delegate yerdy:_delegate handleReward:parser.actionInfo];
						break;
						
					default:
						break;
				}
			}
		}
	} else if (_outcome == YRDMessageOutcomeCancel) {
		[self reportOutcomeToURL:_message.viewURL];
	}
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
