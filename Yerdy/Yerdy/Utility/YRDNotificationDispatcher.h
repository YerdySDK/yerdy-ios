//
//  YRDNotificationDispatcher.h
//  Yerdy
//
//  Created by Darren Clark on 2014-08-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Forwards NSNotifications onto any registered observers in a specified order.
// Observers are notified based on their priority, lower priorities are notified first,
// higher priorities later.
//
// For example, YRDDataStore registers itself as the last observer to the app
// will enter backround/app will exit notifications to ensure all data is persisted

@interface YRDNotificationDispatcher : NSObject

+ (instancetype)sharedDispatcher;

// adds an observer with priority 0
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName;

// adds an observer with a specific priority
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName priority:(int)priority;

// removes an observer for a specific notification
- (void)removeObserver:(id)observer name:(NSString *)notificationName;

// removes an observer for all notifications
- (void)removeObserver:(id)observer;

@end
