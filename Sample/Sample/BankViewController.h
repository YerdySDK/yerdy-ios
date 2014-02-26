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

@property (strong, nonatomic) IBOutlet UITextField *gold;
@property (strong, nonatomic) IBOutlet UITextField *silver;
@property (strong, nonatomic) IBOutlet UITextField *bronze;
@property (strong, nonatomic) IBOutlet UITextField *diamonds;
@property (strong, nonatomic) IBOutlet UITextField *pearls;
@property (strong, nonatomic) IBOutlet UITextField *rubies;

- (IBAction)earn:(id)sender;

@end
