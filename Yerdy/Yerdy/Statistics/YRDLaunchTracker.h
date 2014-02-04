//
//  YRDLaunchTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Managed by Yerdy singleton.
// DO NOT INSTANTIATE AN INSTANCE OF THIS CLASS YOURSELF!

@interface YRDLaunchTracker : NSObject

// Number of launches (for the current version of the app)
@property (nonatomic, readonly) NSInteger launchCount;

// Number of crashes (for the current version of the app)
@property (nonatomic, readonly) NSInteger crashCount;

@end
