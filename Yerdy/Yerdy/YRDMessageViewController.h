//
//  YRDMessageViewController.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-18.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDViewController.h"

@class YRDMessage;
@protocol YRDMessageViewControllerDelegate;


@interface YRDMessageViewController : YRDViewController

@property (nonatomic, weak) id<YRDMessageViewControllerDelegate> delegate;

- (id)initWithWindow:(UIWindow *)window message:(YRDMessage *)message;

// Outlets/actions attached via YRDMessageView
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
- (IBAction)confirmTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end


@protocol YRDMessageViewControllerDelegate <NSObject>
@required
- (void)messageViewControllerFinishedWithConfirm:(YRDMessageViewController *)viewController;
- (void)messageViewControllerFinishedWithCancel:(YRDMessageViewController *)viewController;
@end