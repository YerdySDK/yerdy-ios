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
	
	[self checkVersion];
	[self incrementLaunchesForKey:YRDLaunchesDefaultsKey];
	
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
	if (fabs([_lastBackground timeIntervalSinceNow]) > MinBackgroundTimeForResumeLaunch) {
		[self incrementLaunchesForKey:YRDLaunchesDefaultsKey];
		
		if ([_delegate respondsToSelector:@selector(launchTrackerDetectedResumeLaunch:)]) {
			[_delegate launchTrackerDetectedResumeLaunch:self];
		}
	} else {
		[self incrementLaunchesForKey:YRDResumesDefaultsKey];
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self incrementExits];
}

#pragma mark - Properties

- (NSInteger)launchCount
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:YRDLaunchesDefaultsKey];
}

- (NSInteger)crashCount
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger launches = [defaults integerForKey:YRDLaunchesDefaultsKey];
	NSInteger resumes = [defaults integerForKey:YRDResumesDefaultsKey];
	NSInteger exits = [defaults integerForKey:YRDExitsDefaultsKey];
	
	NSInteger crashes = launches + resumes - exits;
	// launches + resumes will be 1 higher than exits if we haven't exited the app yet
	if (!_countedExit)
		crashes -= 1;
	
	return crashes;
}

#pragma mark - Launch tracking

- (void)incrementLaunchesForKey:(NSString *)key
{
	if (_countedLaunch)
		return;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger launches = [defaults integerForKey:key];
	
	// fix messed up counters
	if (launches < 0) {
		[self reset];
		launches = 0;
	}
	
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
	NSInteger exits = [defaults integerForKey:YRDExitsDefaultsKey];
	
	// fix messed up counters
	if (exits < 0) {
		[self reset];
		exits = 0;
	}
	
	[defaults setInteger:exits + 1 forKey:YRDExitsDefaultsKey];
	[defaults synchronize];
	_countedLaunch = NO;
	_countedExit = YES;
}

- (void)checkVersion
{
	// Launches/crashes are tracked per version, so we need to reset the counters
	// when we detect a new version of the application
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *lastKnownAppVersion = [defaults objectForKey:YRDAppVersionDefaultsKey];
	NSString *appVersion = [YRDUtil appVersion];
	
	if (lastKnownAppVersion && ![lastKnownAppVersion isEqualToString:appVersion]) {
		[self reset];
	}
}

- (void)reset
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *appVersion = [YRDUtil appVersion];
	[defaults setObject:appVersion forKey:YRDAppVersionDefaultsKey];
	
	[defaults setInteger:0 forKey:YRDLaunchesDefaultsKey];
	[defaults setInteger:0 forKey:YRDResumesDefaultsKey];
	[defaults setInteger:0 forKey:YRDExitsDefaultsKey];
}

@end
