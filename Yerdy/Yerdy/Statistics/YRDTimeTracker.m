//
//  YRDTimeTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-17.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTimeTracker.h"
#import "YRDConstants.h"
#import "YRDDataStore.h"
#import "YRDLog.h"
#import "YRDNotificationDispatcher.h"
#import "YRDTimer.h"

#import <UIKit/UIKit.h>


NSString *YRDTimeTrackerMinutePassedNotification = @"YRDTimeTrackerMinutePassed";
NSString *YRDTimeTrackerMinutesPassedKey = @"minutesPassed";
NSString *YRDTimeTrackerTimePlayedKey = @"timePlayed";


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
		
	[[YRDNotificationDispatcher sharedDispatcher] addObserver:self selector:@selector(applicationDidEnterBackground:)
												 name:UIApplicationDidEnterBackgroundNotification];
	[[YRDNotificationDispatcher sharedDispatcher] addObserver:self selector:@selector(applicationWillEnterForeground:)
												 name:UIApplicationWillEnterForegroundNotification];
	[[YRDNotificationDispatcher sharedDispatcher] addObserver:self selector:@selector(applicationWillTerminate:)
												 name:UIApplicationWillTerminateNotification];
	
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
	NSTimeInterval timePlayed = [[YRDDataStore sharedDataStore] doubleForKey:YRDTimePlayedDefaultsKey];
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
	
	YRDDataStore *dataStore = [YRDDataStore sharedDataStore];
	
	// update time played
	NSTimeInterval timePlayed = [dataStore doubleForKey:YRDTimePlayedDefaultsKey];
	timePlayed += timePassed;
	[dataStore setDouble:timePlayed forKey:YRDTimePlayedDefaultsKey];
	
	// determine whether or not we should fire a YRDTimeTrackerMinutePassedNotification
	NSInteger lastMinutesReported = [dataStore integerForKey:YRDMinutesPlayedDefaultsKey];
	int minutesPassed = (int)(round(timePlayed + (FireInterval * ToleranceRatio)) / 60.0);
	
	// very unlikely, but if things get really out of whack, we may fire 2 (or more) notifications
	for (NSInteger i = lastMinutesReported + 1; i <= minutesPassed; i++) {
		NSDictionary *userInfo = @{
			YRDTimeTrackerMinutesPassedKey : @(i),
			YRDTimeTrackerTimePlayedKey : @(timePlayed)
		};
		
		YRDDebug(@"Firing %@: %@", YRDTimeTrackerMinutePassedNotification, userInfo);
		[[NSNotificationCenter defaultCenter] postNotificationName:YRDTimeTrackerMinutePassedNotification
															object:self userInfo:userInfo];
	}
	[dataStore setInteger:minutesPassed forKey:YRDMinutesPlayedDefaultsKey];
}


- (NSTimeInterval)timePlayed
{
	YRDDataStore *dataStore = [YRDDataStore sharedDataStore];
	NSTimeInterval timePlayed = [dataStore doubleForKey:YRDTimePlayedDefaultsKey];
	
	NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:_lastCheckpoint];
	
	// only add timePassed if it isn't a really weird value
	if (!(timePassed <= 0.0 || timePassed >= FireInterval * ErrorRatio)) {
		timePlayed += timePassed;
	}
	
	return timePlayed;
}


- (NSTimeInterval)versionTimePlayed
{
	YRDDataStore *dataStore = [YRDDataStore sharedDataStore];
	NSTimeInterval startOffset = [dataStore doubleForKey:YRDVersionStartTimeOffsetDefaultsKey];
	return self.timePlayed - startOffset;
}

- (void)resetVersionTimePlayed
{
	YRDDataStore *dataStore = [YRDDataStore sharedDataStore];
	[dataStore setDouble:self.timePlayed forKey:YRDVersionStartTimeOffsetDefaultsKey];
}

@end
