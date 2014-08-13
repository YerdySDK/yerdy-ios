//
//  ViewController.m
//  Sample
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "ViewController.h"
#import "BankViewController.h"
#import "FakeAd.h"
#import "Yerdy.h"

#import <iAd/iAd.h>

static NSString *iAdNetworkName = @"iAd";
static NSString *FakeAdNetworkName = @"FakeAd";

@interface ViewController () <YerdyMessageDelegate, ADInterstitialAdDelegate, FakeAdDelegate>
{
	ADInterstitialAd *_interstitial;
	UIView *_interstitialContainer;
	
	FakeAd *_fakeAd;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[Yerdy sharedYerdy] logScreenVisit:@"main"];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
		&& NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
		_adButton.enabled = NO;
		[_adButton setTitle:@"Unavailable on iOS < 7 iPhones" forState:UIControlStateNormal];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showMessaging
{
	Yerdy *yerdy = [Yerdy sharedYerdy];
	yerdy.messageDelegate = self;
	
	BOOL hasMessage = [yerdy isMessageAvailable:@"launch"];
	NSLog(@"Message available for 'launch' placement? %s", hasMessage ? "yes" : "no");
	
	if (hasMessage) {
		[yerdy showMessage:@"launch"];
	}
}

- (IBAction)showBank:(id)sender
{
	BankViewController *bankViewController = [[BankViewController alloc] initWithNibName:nil bundle:nil];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		bankViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	[self presentViewController:bankViewController animated:YES completion:NULL];
}

- (IBAction)logButtonPressEvent:(id)sender
{
	NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
	
	[[Yerdy sharedYerdy] logEvent:@"buttonPressed" parameters:@{ @"title" : buttonTitle }];
}

- (IBAction)logPlayerProgression:(id)sender
{
	NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
	
	if ([buttonTitle isEqualToString:@"level-1"]) {
		[[Yerdy sharedYerdy] startPlayerProgression:@"level" initialMilestone:@"level-1"];
	} else {
		[[Yerdy sharedYerdy] logPlayerProgression:@"level" milestone:buttonTitle];
	}
}

- (IBAction)requestAd:(id)sender
{
	if (_interstitial || _fakeAd) {
		return;
	}
	
	[[Yerdy sharedYerdy] logAdRequest:iAdNetworkName];
	
	_adButton.enabled = _fakeAdButton.enabled = NO;
	
	_interstitial = [[ADInterstitialAd alloc] init];
	_interstitial.delegate = self;
}

- (IBAction)requestFakeAd:(id)sender
{
	if (_fakeAd || _interstitial)
		return;
	
	[[Yerdy sharedYerdy] logAdRequest:FakeAdNetworkName];
	
	_adButton.enabled = _fakeAdButton.enabled = NO;
	
	_fakeAd = [[FakeAd alloc] init];
	_fakeAd.delegate = self;
	[_fakeAd requestAd];
}

#pragma mark - Yerdy

- (void)yerdy:(Yerdy *)yerdy willPresentMessageForPlacement:(NSString *)placement
{
	NSLog(@"*** %@", NSStringFromSelector(_cmd));
}

- (void)yerdy:(Yerdy *)yerdy didPresentMessageForPlacement:(NSString *)placement
{
	NSLog(@"*** %@", NSStringFromSelector(_cmd));
}

- (void)yerdy:(Yerdy *)yerdy willDismissMessageForPlacement:(NSString *)placement
{
	NSLog(@"*** %@", NSStringFromSelector(_cmd));
}

- (void)yerdy:(Yerdy *)yerdy didDismissMessageForPlacement:(NSString *)placement
{
	NSLog(@"*** %@", NSStringFromSelector(_cmd));
}

- (void)yerdy:(Yerdy *)yerdy handleInAppPurchase:(YRDInAppPurchase *)purchase
{
	NSLog(@"Trying IAP purchase: %@", purchase.productIdentifier);
	
	// TODO: Call report purchase
}

- (void)yerdy:(Yerdy *)yerdy handleItemPurchase:(YRDItemPurchase *)purchase
{
	NSLog(@"Trying item purchase: %@", purchase.item);
	
	// TODO: Call report item purchase
}

- (void)yerdy:(Yerdy *)yerdy handleReward:(YRDReward *)reward
{
	NSLog(@"Rewarding user: %@", reward.rewards);
}

- (void)yerdy:(Yerdy *)yerdy handleNavigation:(NSString *)screenName
{
	NSLog(@"Showing: %@", screenName);
	if ([screenName isEqual:@"bank"]) {
		[self showBank:nil];
	}
}

#pragma mark - iAd


- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
	[[Yerdy sharedYerdy] logAdFill:iAdNetworkName];
	
	if (_interstitialContainer)
		[_interstitialContainer removeFromSuperview];
	
	_interstitialContainer = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_interstitialContainer];
	
	[_interstitial presentInView:_interstitialContainer];
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
	_interstitial.delegate = nil;
	_interstitial = nil;
	_adButton.enabled = _fakeAdButton.enabled = YES;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ad Failed"
													message:[NSString stringWithFormat:@"Failed to load ad: %@", error.localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
	_interstitial.delegate = nil;
	_interstitial = nil;
	_adButton.enabled = _fakeAdButton.enabled = YES;
	
	[_interstitialContainer removeFromSuperview];
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
	_interstitial.delegate = nil;
	_interstitial = nil;
	_adButton.enabled = _fakeAdButton.enabled = YES;
	
	[_interstitialContainer removeFromSuperview];
}

#pragma mark - FakeAd

- (void)fakeAdFetchedAd:(FakeAd *)ad
{
	[[Yerdy sharedYerdy] logAdFill:FakeAdNetworkName];
	
	[_fakeAd showAd];
}

- (void)fakeAdDismissed:(FakeAd *)ad
{
	_fakeAd = nil;
	_adButton.enabled = _fakeAdButton.enabled = YES;
}

- (void)fakeAd:(FakeAd *)ad failedWithError:(NSError *)error
{
	_fakeAd = nil;
	_adButton.enabled = _fakeAdButton.enabled = YES;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ad Failed"
													message:[NSString stringWithFormat:@"Failed to load ad: %@", error.localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

@end
