//
//  ViewController.m
//  Sample
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "ViewController.h"
#import "BankViewController.h"
#import "Yerdy.h"

@interface ViewController () <YerdyMessageDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[Yerdy sharedYerdy] logScreenVisit:@"main"];
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
	
	BOOL hasMessage = [yerdy messageAvailable:@"launch"];
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

@end
