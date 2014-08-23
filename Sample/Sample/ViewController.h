//
//  ViewController.h
//  Sample
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *adButton;
@property (nonatomic, strong) IBOutlet UIButton *fakeAdButton;

- (void)showMessaging;

- (IBAction)showBank:(id)sender;

- (IBAction)logFeatureUse:(id)sender;
- (IBAction)logPlayerProgression:(id)sender;

- (IBAction)requestAd:(id)sender;
- (IBAction)requestFakeAd:(id)sender;

@end
