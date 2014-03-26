//
//  AppDelegate.m
//  Sample
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "AppDelegate.h"
#import "BankViewController.h"
#import "ViewController.h"

#import "HTTPMock.h"

#import "Yerdy.h"

#import "PublisherKey.h"


static const BOOL TREAT_AS_EXISTING_USER = NO;


@interface AppDelegate () <YerdyDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[Yerdy setLogLevel:YRDLogDebug];
	
	Yerdy *yerdy = [Yerdy startWithPublisherKey:PUBLISHER_KEY];
	[yerdy registerCurrencies:@[ Gold, Silver, Bronze, Diamonds, Pearls, Rubies ]];
	[yerdy setMaxFailoverCount:0 forPlacement:@"launch2"];
	yerdy.delegate = self;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *initialCurrency = @{ Gold : @30, Silver : @20, Bronze : @10 };

	BOOL initialized = [[defaults objectForKey:@"Initialized"] boolValue];
	if (!initialized) {
		[defaults setObject:@YES forKey:@"Initialized"];
		
		for (NSString *key in initialCurrency) {
			[defaults setObject:initialCurrency[key] forKey:key];
		}
		
		if (TREAT_AS_EXISTING_USER) {
			[yerdy setExistingCurrenciesForExistingUser:initialCurrency];
		} else {
			[yerdy earnedCurrencies:initialCurrency];
		}
	}
	
	CGRect screenBounds = [UIScreen mainScreen].bounds;
	_window = [[UIWindow alloc] initWithFrame:screenBounds];
	_window.backgroundColor = [UIColor whiteColor];
	[_window makeKeyAndVisible];
	
	_viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
	_viewController.view.frame = _window.bounds;
	[_window addSubview:_viewController.view];
	_window.rootViewController = _viewController;
	
	[HTTPMock enableWithPlist:@"HTTPMock.plist"];
	
	// Fake getting a push token
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		yerdy.pushToken = [NSData data];
	});
	
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
	
	[_viewController showMessaging];
}

@end
