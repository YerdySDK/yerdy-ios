//
//  BankViewController.m
//  Sample
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "BankViewController.h"
#import "Yerdy.h"

NSString *Gold = @"Gold",
		*Silver = @"Silver",
		*Bronze = @"Bronze",
		*Diamonds = @"Diamonds",
		*Pearls = @"Pearls",
		*Rubies = @"Rubies";


@interface BankViewController ()

@end

@implementation BankViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)currenciesFromTextFields
{
	NSMutableDictionary *currencies = [NSMutableDictionary dictionary];
	if (_gold.text.length > 0)
		currencies[Gold] = @(_gold.text.intValue);
	if (_silver.text.length > 0)
		currencies[Silver] = @(_silver.text.intValue);
	if (_bronze.text.length > 0)
		currencies[Bronze] = @(_bronze.text.intValue);
	if (_diamonds.text.length > 0)
		currencies[Diamonds] = @(_diamonds.text.intValue);
	if (_pearls.text.length > 0)
		currencies[Pearls] = @(_pearls.text.intValue);
	if (_rubies.text.length > 0)
		currencies[Rubies] = @(_rubies.text.intValue);
	return currencies;
}

- (IBAction)earn:(id)sender
{
	Yerdy *yerdy = [Yerdy sharedYerdy];
	
	NSDictionary *currencies = [self currenciesFromTextFields];
	
	if (currencies.count == 1)
		[yerdy earnedCurrency:currencies.allKeys[0]
					   amount:[currencies.allValues[0] unsignedIntegerValue]];
	else
		[yerdy earnedCurrencies:currencies];
}

@end
