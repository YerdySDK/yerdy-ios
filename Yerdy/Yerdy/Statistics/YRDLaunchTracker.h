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

@protocol YRDLaunchTrackerDelegate;


@interface YRDLaunchTracker : NSObject

@property (nonatomic, weak) id<YRDLaunchTrackerDelegate> delegate;

// Number of launches (for the current version of the app)
@property (nonatomic, readonly) NSInteger launchCount;

// Number of crashes (for the current version of the app)
@property (nonatomic, readonly) NSInteger crashCount;

@end


@protocol YRDLaunchTrackerDelegate <NSObject>
@optional

// Triggered after the app is resumed after sitting in the background for 15 minutes
- (void)launchTrackerDetectedResumeLaunch:(YRDLaunchTracker *)launchTracker;

@end
