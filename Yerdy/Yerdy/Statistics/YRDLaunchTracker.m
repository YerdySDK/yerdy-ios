//
//  YRDLaunchTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDLaunchTracker.h"
#import "YRDConstants.h"
#import "YRDUtil.h"
#import <UIKit/UIKit.h>

// Application enter/exits are counted in 3 different buckets:
//
// - launches (YRDLaunchesDefaultsKey):  Launches of the app when the user has been away
//		for a while (for example, on a fresh launch of the app or after resuming from
//		the background after a significant period of time)
// - resumes (YRDResumesDefaultsKey):  Resuming from the background in a short period
//		of time (for example, if the user quickly swapped out of the app to respond
//		to a text message)
// - exits (YRDExitsDefaultsKey): When the application is backgrounded or terminated
//		gracefully
//
// This allows us to easily calculate crashes (launches + resumes - exits - 1)


static const NSTimeInterval MinBackgroundTimeForResumeLaunch = 15.0 * 60.0;

typedef enum YRDLaunchCounterType {
	YRDLaunchCounterResume,
	YRDLaunchCounterLaunch,
} YRDLaunchCounterType;

@interface YRDLaunchTracker ()
{
	BOOL _countedLaunch;
	BOOL _countedExit;
	
	NSDate *_lastBackground;
}
@end


@implementation YRDLaunchTracker

#pragma mark - Object Lifecycle

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
	
	_countedLaunch = NO;
	_countedExit = YES;
	
	[self incrementLaunchesForType:YRDLaunchCounterLaunch];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIApplication notifications

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
	_lastBackground = [NSDate date];
	[self incrementExits];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
	YRDResumeType resumeType;
	
	if (fabs([_lastBackground timeIntervalSinceNow]) > MinBackgroundTimeForResumeLaunch) {
		resumeType = YRDLongResume;
		[self incrementLaunchesForType:YRDLaunchCounterLaunch];
	} else {
		resumeType = YRDShortResume;
		[self incrementLaunchesForType:YRDLaunchCounterResume];
	}
	
	if ([_delegate respondsToSelector:@selector(launchTracker:detectedResumeOfType:)]) {
		[_delegate launchTracker:self detectedResumeOfType:resumeType];
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self incrementExits];
}

#pragma mark - Properties

- (NSInteger)versionLaunchCount
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:YRDVersionLaunchesDefaultsKey];
}

- (NSInteger)versionCrashCount
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger launches = [defaults integerForKey:YRDVersionLaunchesDefaultsKey];
	NSInteger resumes = [defaults integerForKey:YRDVersionResumesDefaultsKey];
	NSInteger exits = [defaults integerForKey:YRDVersionExitsDefaultsKey];
	
	NSInteger crashes = launches + resumes - exits;
	// launches + resumes will be 1 higher than exits if we haven't exited the app yet
	if (!_countedExit)
		crashes -= 1;
	
	return crashes;
}

- (NSInteger)totalLaunchCount
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:YRDTotalLaunchesDefaultsKey];
}

#pragma mark - Launch tracking

- (void)incrementLaunchesForType:(YRDLaunchCounterType)type
{
	if (_countedLaunch)
		return;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *key = nil;
	if (type == YRDLaunchCounterLaunch) {
		key = YRDVersionLaunchesDefaultsKey;
		
		NSInteger totalLaunches = [defaults integerForKey:YRDTotalLaunchesDefaultsKey];
		totalLaunches += 1;
		[defaults setInteger:totalLaunches forKey:YRDTotalLaunchesDefaultsKey];
	} else if (type == YRDLaunchCounterResume) {
		key = YRDVersionResumesDefaultsKey;
	}
	
	NSInteger launches = [defaults integerForKey:key];
	
	[defaults setInteger:launches + 1 forKey:key];
	[defaults synchronize];
	_countedLaunch = YES;
	_countedExit = NO;
}

- (void)incrementExits
{
	if (_countedExit)
		return;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger exits = [defaults integerForKey:YRDVersionExitsDefaultsKey];
	
	[defaults setInteger:exits + 1 forKey:YRDVersionExitsDefaultsKey];
	[defaults synchronize];
	_countedLaunch = NO;
	_countedExit = YES;
}

- (void)reset
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setInteger:1 forKey:YRDVersionLaunchesDefaultsKey];
	[defaults setInteger:0 forKey:YRDVersionResumesDefaultsKey];
	[defaults setInteger:0 forKey:YRDVersionExitsDefaultsKey];
}

@end
