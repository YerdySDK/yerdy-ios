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
	
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		Yerdy *yerdy = [Yerdy sharedYerdy];
		[yerdy showMessage:placement];
	});
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
