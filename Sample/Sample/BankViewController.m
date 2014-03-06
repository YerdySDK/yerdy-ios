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

static NSString *GoldProductIdentifier = @"com.yerdy.Sample.Gold";
static NSString *JewelPackProductIdentifier = @"com.yerdy.Sample.JewelPack";


@interface BankViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate>
{
	NSDictionary *_iapProducts;
}
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
	[[Yerdy sharedYerdy] logScreenVisit:@"bank"];
	[self updateDisplay];
	
	SKPaymentQueue *queue = [SKPaymentQueue defaultQueue];
	[queue removeTransactionObserver:self];
	[queue addTransactionObserver:self];
	
	NSSet *products = [NSSet setWithObjects:GoldProductIdentifier, JewelPackProductIdentifier, nil];
	SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
	productsRequest.delegate = self;
	[productsRequest start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)earn:(id)sender
{
	NSDictionary *currencies = [self currenciesFromTextFields];
	
	[self incrementCurrencies:currencies];
	
	
	Yerdy *yerdy = [Yerdy sharedYerdy];
	// ensure both methods are tested...
	if (currencies.count == 1)
		[yerdy earnedCurrency:currencies.allKeys[0]
					   amount:[currencies.allValues[0] unsignedIntegerValue]];
	else
		[yerdy earnedCurrencies:currencies];
}

- (IBAction)buyItem:(id)sender
{
	if (_itemName.text.length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please enter an item name"
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSDictionary *currencies = [self currenciesFromTextFields];
	for (NSString *currencyName in currencies) {
		NSInteger balance = [defaults integerForKey:currencyName];
		if (balance < [currencies[currencyName] integerValue]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Insufficient funds" message:nil
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			return;
		}
	}
	
	[self decrementCurrencies:currencies];
	
	
	Yerdy *yerdy = [Yerdy sharedYerdy];
	// ensure both methods are tested...
	if (currencies.count == 1 && !_purchasesOnSale.isOn)
		[yerdy purchasedItem:_itemName.text withCurrency:currencies.allKeys[0]
					  amount:[currencies.allValues[0] unsignedIntegerValue]];
	else
		[yerdy purchasedItem:_itemName.text withCurrencies:currencies onSale:_purchasesOnSale.isOn];
}

- (IBAction)buyGold:(id)sender
{
	[self startPurchase:GoldProductIdentifier];
}

- (IBAction)buyJewelPack:(id)sender
{
	[self startPurchase:JewelPackProductIdentifier];
}

#pragma mark - Currency input/display

- (NSDictionary *)currenciesFromTextFields
{
	NSMutableDictionary *currencies = [NSMutableDictionary dictionary];
	if (_goldInput.text.length > 0)
		currencies[Gold] = @(_goldInput.text.intValue);
	if (_silverInput.text.length > 0)
		currencies[Silver] = @(_silverInput.text.intValue);
	if (_bronzeInput.text.length > 0)
		currencies[Bronze] = @(_bronzeInput.text.intValue);
	if (_diamondsInput.text.length > 0)
		currencies[Diamonds] = @(_diamondsInput.text.intValue);
	if (_pearlsInput.text.length > 0)
		currencies[Pearls] = @(_pearlsInput.text.intValue);
	if (_rubiesInput.text.length > 0)
		currencies[Rubies] = @(_rubiesInput.text.intValue);
	return currencies;
}

- (void)updateDisplay
{
	NSDictionary *labels = @{
		Gold : _gold,
		Silver : _silver,
		Bronze : _bronze,
		Diamonds : _diamonds,
		Pearls : _pearls,
		Rubies : _rubies,
	};
	
	for (NSString *currency in labels) {
		UILabel *label = labels[currency];
		int value = [[NSUserDefaults standardUserDefaults] integerForKey:currency];
		label.text = [NSString stringWithFormat:@"%d", value];
	}
}

- (void)incrementCurrencies:(NSDictionary *)currencies
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	for (NSString *currencyName in currencies) {
		int change = [currencies[currencyName] intValue];
		NSInteger current = [defaults integerForKey:currencyName];
		[defaults setInteger:current + change forKey:currencyName];
	}
	
	[self updateDisplay];
}

- (void)decrementCurrencies:(NSDictionary *)currencies
{
	NSMutableDictionary *negative = [NSMutableDictionary dictionary];
	for (NSString *key in currencies) {
		negative[key] = @(-1 * [currencies[key] intValue]);
	}
	[self incrementCurrencies:negative];
}

- (void)updateButton:(UIButton *)button withProduct:(SKProduct *)product
{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	formatter.numberStyle = NSNumberFormatterCurrencyStyle;
	formatter.locale = product.priceLocale;
	NSString *priceString = [formatter stringFromNumber:product.price];
	
	NSString *buttonTitle = [NSString stringWithFormat:@"%@ (%@)", product.localizedTitle, priceString];
	[button setTitle:buttonTitle forState:UIControlStateNormal];
	
	button.hidden = NO;
}

#pragma mark - Alerts

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
												   delegate:nil cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

#pragma mark - Store Kit

- (void)startPurchase:(NSString *)productIdentifier
{
	SKProduct *product = _iapProducts[productIdentifier];
	if (!product) {
		NSLog(@"Unable to find product with identifier: %@", productIdentifier);
		return;
	}
	
	SKPayment *payment = [SKPayment paymentWithProduct:product];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	if (response.invalidProductIdentifiers.count > 0)
		NSLog(@"Invalid product identifiers: %@", response.invalidProductIdentifiers);
	
	NSMutableDictionary *products = [NSMutableDictionary dictionary];
	for (SKProduct *product in response.products) {
		products[product.productIdentifier] = product;
	}
	_iapProducts = products;
	
	
	if (_iapProducts[GoldProductIdentifier]) {
		SKProduct *product = _iapProducts[GoldProductIdentifier];
		[self updateButton:_buyGoldButton withProduct:product];
	}
	
	if (_iapProducts[JewelPackProductIdentifier]) {
		SKProduct *product = _iapProducts[JewelPackProductIdentifier];
		[self updateButton:_buyJewelPackButton withProduct:product];
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchasing:
				NSLog(@"Purchasing: %@", transaction.payment.productIdentifier);
				break;
				
			case SKPaymentTransactionStatePurchased:
				NSLog(@"Purchased: %@", transaction.payment.productIdentifier);
				[self purchaseSuccessful:transaction];
				[queue finishTransaction:transaction];
				break;
				
			case SKPaymentTransactionStateFailed:
				[self showAlertWithTitle:@"Purchase Failed" message:[transaction.error localizedDescription]];
				NSLog(@"Failed: %@: %@", transaction.payment.productIdentifier, transaction.error);
				[queue finishTransaction:transaction];
				break;
				
			case SKPaymentTransactionStateRestored:
				NSLog(@"Restored: %@", transaction.payment.productIdentifier);
				[queue finishTransaction:transaction];
				break;
				
			default:
				break;
		}
	}
}

- (void)purchaseSuccessful:(SKPaymentTransaction *)transaction
{
	[self showAlertWithTitle:@"Purchase Successful!" message:transaction.payment.productIdentifier];
	
	NSString *productIdentifier = transaction.payment.productIdentifier;
	
	if ([productIdentifier isEqualToString:GoldProductIdentifier]) {
		[self incrementCurrencies:@{ Gold : @50 }];
		
		YRDPurchase *purchase = [YRDPurchase purchaseWithTransaction:transaction];
		purchase.sandboxStore = YES; // never going to be released to App Store, hardcode to YES
		purchase.onSale = _purchasesOnSale.isOn;
		[[Yerdy sharedYerdy] purchasedInApp:purchase currency:Gold amount:50];
	} else if ([productIdentifier isEqualToString:JewelPackProductIdentifier]) {
		NSDictionary *currencies = @{ Diamonds : @50, Pearls : @50, Rubies: @50 };
		[self incrementCurrencies:currencies];
		
		YRDPurchase *purchase = [YRDPurchase purchaseWithProduct:_iapProducts[JewelPackProductIdentifier]
													 transaction:transaction];
		purchase.sandboxStore = YES; // never going to be released to App Store, hardcode to YES
		purchase.onSale = _purchasesOnSale.isOn;
		[[Yerdy sharedYerdy] purchasedInApp:purchase currencies:currencies];
	}
}

@end
