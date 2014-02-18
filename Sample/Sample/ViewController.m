//
//  ViewController.m
//  Sample
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "ViewController.h"
#import "Yerdy.h"

@interface ViewController () <YerdyMessageDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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


- (void)yerdy:(Yerdy *)yerdy handleInAppPurchase:(YRDInAppPurchase *)purchase
{
	NSLog(@"Trying IAP purchase: %@", purchase.productIdentifier);
	
	// pretend it failed
	double delayInSeconds = 1.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSLog(@"Purchase failure: %@", purchase.productIdentifier);
		[purchase reportFailure];
	});
}

- (void)yerdy:(Yerdy *)yerdy handleItemPurchase:(YRDItemPurchase *)purchase
{
	NSLog(@"Trying item purchase: %@", purchase.item);
	
	// pretend that they succeesfully made the purchase
	double delayInSeconds = 1.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSLog(@"Purchase success: %@", purchase.item);
		[purchase reportSuccess];
	});
}

- (void)yerdy:(Yerdy *)yerdy handleReward:(YRDReward *)reward
{
	NSLog(@"Rewarding user: %@", reward.rewards);
}

@end
