//
//  AppDelegate.m
//  Sample
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "HTTPMock.h"

#import "Yerdy.h"
#import "YRDLog.h"

@interface AppDelegate () <YerdyDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	CGRect screenBounds = [UIScreen mainScreen].bounds;
	_window = [[UIWindow alloc] initWithFrame:screenBounds];
	_window.backgroundColor = [UIColor whiteColor];
	[_window makeKeyAndVisible];
	
	_viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
	_viewController.view.frame = _window.bounds;
	[_window addSubview:_viewController.view];
	_window.rootViewController = _viewController;
	
	[HTTPMock enableWithPlist:@"HTTPMock.plist"];
	
	YRDSetLogLevel(YRDLogDebug);
	
	Yerdy *yerdy = [Yerdy startWithPublisherKey:@"<INSERT PUBLISHER KEY HERE>"];
	yerdy.delegate = self;
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Yerdy Delegate

- (void)yerdyConnected
{
	NSLog(@"Yerdy Connected...");
	
	BOOL hasLaunchMessage = [[Yerdy sharedYerdy] messageAvailable:@"launch"];
	NSLog(@"Message available for 'launch' placement? %s", hasLaunchMessage ? "yes" : "no");
	
	if (hasLaunchMessage) {
		[[Yerdy sharedYerdy] showMessage:@"launch"];
	}
}

@end
