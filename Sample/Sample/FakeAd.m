//
//  FakeAd.m
//  Sample
//
//  Created by Darren Clark on 2014-05-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "FakeAd.h"

@interface FakeAd () <UIAlertViewDelegate>
{
	UIAlertView *_alertView;
}
@end


@implementation FakeAd

- (void)requestAd
{
	int roll = (arc4random() % 100);
	BOOL success = roll	> 25;
	
	__weak FakeAd *weakSelf = self;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		FakeAd *strongSelf = weakSelf;
		if (success) {
			if ([strongSelf.delegate respondsToSelector:@selector(fakeAdFetchedAd:)]) {
				[strongSelf.delegate fakeAdFetchedAd:strongSelf];
			}
		} else {
			if ([strongSelf.delegate respondsToSelector:@selector(fakeAd:failedWithError:)]) {
				NSError *error = [NSError errorWithDomain:@"FakeAdErrorDomain"
													 code:0
												 userInfo:@{ NSLocalizedDescriptionKey : @"Randomly rolled an ad failure" }];
				[strongSelf.delegate fakeAd:strongSelf failedWithError:error];
			}
		}
	});
}

- (void)showAd
{
	_alertView = [[UIAlertView alloc] initWithTitle:@"FakeAd"
											message:@"This is a fake test ad, for the purposes of testing ad requests/fills tracking"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
	[_alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ([_delegate respondsToSelector:@selector(fakeAdDismissed:)])
		[_delegate fakeAdDismissed:self];
}

@end
