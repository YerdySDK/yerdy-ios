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
typedef enum YRDResumeType {
	// Short (< 15 minutes) time spent in background, user *probably* only backgrounded
	// the app to respond to a text or tweet, etc...
	YRDShortResume,
	// Long (> 15 minutes) time spent in background, user probably left the app and it
	// just never got kicked out of memory. For all intents and purposes we count this
	// as a new launch of the app
	YRDLongResume,
} YRDResumeType;


@interface YRDLaunchTracker : NSObject

@property (nonatomic, weak) id<YRDLaunchTrackerDelegate> delegate;

// Number of launches (for the current version of the app)
@property (nonatomic, readonly) NSInteger launchCount;

// Number of crashes (for the current version of the app)
@property (nonatomic, readonly) NSInteger crashCount;

- (void)reset;

@end


@protocol YRDLaunchTrackerDelegate <NSObject>
@optional

// Triggered after the app is resumed after sitting in the background for 15 minutes
- (void)launchTracker:(YRDLaunchTracker *)launchTracker detectedResumeOfType:(YRDResumeType)resumeType;

@end
