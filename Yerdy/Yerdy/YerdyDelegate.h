//
//  YerdyDelegate.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YerdyDelegate <NSObject>
@optional

// Called when a successful connection has been made to the Yerdy servers and
// messages have been downloaded
- (void)yerdyConnected;

@end
