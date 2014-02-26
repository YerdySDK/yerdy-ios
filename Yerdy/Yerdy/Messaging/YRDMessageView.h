//
//  YRDMessageView.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-18.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YRDMessage, YRDMessageViewController;


@interface YRDMessageView : UIView

// A strong reference is NOT held to 'viewController' (prevents a retain cycle)
- (id)initWithViewController:(YRDMessageViewController *)viewController message:(YRDMessage *)message;

@end
