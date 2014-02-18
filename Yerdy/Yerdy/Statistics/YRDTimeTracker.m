//
//  YRDTimeTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-17.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTimeTracker.h"
#import "YRDConstants.h"
#import "YRDTimer.h"

#import <UIKit/UIKit.h>


// fire every minute
static const NSTimeInterval FireInterval = 60.0;

// ratio of FireInterval to use for the NSTimer's tolerance value
static const double ToleranceRatio = 0.1;

// ratio of FireInterval to use as a threshold for discarding timer firings
// (for example, if NTP updates their device time, etc..)
static const double ErrorRatio = 2.0;


@interface YRDTimeTracker () <YRDTimerTarget>
{
	NSDate *_lastCheckpoint;
	YRDTimer *_timer;
}
@end


@implementation YRDTimeTracker

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
												 name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:)
												 name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:)
												 name:UIApplicationWillTerminateNotification object:nil];
	
	[self startTimer];
	
	return self;
}


- (void)applicationDidEnterBackground:(NSNotification *)notification
{
	[self stopTimer];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
	[self startTimer];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self stopTimer];
}

- (void)timerFired:(YRDTimer *)timer
{
	[self hitCheckpoint];
}

- (void)startTimer
{
	if (_timer)
		return;
	
	// attempt to calculate startOffset so that the next timer fires on a multiple of TimeInterval
	NSTimeInterval timePlayed = [[NSUserDefaults standardUserDefaults] doubleForKey:YRDTimePlayedDefaultsKey];
	NSTimeInterval startOffset = ceil(timePlayed/FireInterval) * FireInterval - timePlayed;
	
	_lastCheckpoint = [NSDate date];
	_timer = [[YRDTimer alloc] initWithTimeInterval:FireInterval target:self
										  tolerance:FireInterval * ToleranceRatio
										startOffset:startOffset];
}

- (void)stopTimer
{
	if (!_timer)
		return;
	
	[self hitCheckpoint];
	_lastCheckpoint = nil;
	
	[_timer invalidate];
	_timer = nil;
}

- (void)hitCheckpoint
{
	if (_lastCheckpoint == nil)
		return;
	
	NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:_lastCheckpoint];
	_lastCheckpoint = [NSDate date];
	
	if (timePassed <= 0.0 || timePassed >= FireInterval * ErrorRatio) {
		// ignore any really weird values (for example, if NTP updates their device time,
		// etc...)
		return;
	}
	
	// update time played
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSTimeInterval timePlayed = [userDefaults doubleForKey:YRDTimePlayedDefaultsKey];
	timePlayed += timePassed;
	[userDefaults setDouble:timePlayed forKey:YRDTimePlayedDefaultsKey];
}

@end
