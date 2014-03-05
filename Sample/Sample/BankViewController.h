//
//  BankViewController.h
//  Sample
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *Gold, *Silver, *Bronze, *Diamonds, *Pearls, *Rubies;


@interface BankViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *gold;
@property (strong, nonatomic) IBOutlet UILabel *silver;
@property (strong, nonatomic) IBOutlet UILabel *bronze;
@property (strong, nonatomic) IBOutlet UILabel *diamonds;
@property (strong, nonatomic) IBOutlet UILabel *pearls;
@property (strong, nonatomic) IBOutlet UILabel *rubies;

@property (strong, nonatomic) IBOutlet UITextField *goldInput;
@property (strong, nonatomic) IBOutlet UITextField *silverInput;
@property (strong, nonatomic) IBOutlet UITextField *bronzeInput;
@property (strong, nonatomic) IBOutlet UITextField *diamondsInput;
@property (strong, nonatomic) IBOutlet UITextField *pearlsInput;
@property (strong, nonatomic) IBOutlet UITextField *rubiesInput;

- (IBAction)earn:(id)sender;


@property (strong, nonatomic) IBOutlet UITextField *itemName;
- (IBAction)buyItem:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *buyGoldButton;
- (IBAction)buyGold:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *buyJewelPackButton;
- (IBAction)buyJewelPack:(id)sender;


@property (strong, nonatomic) IBOutlet UISwitch *purchasesOnSale;

@end
