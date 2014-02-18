//
//  YRDTimeTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-17.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Posted every minute (or very close to) of gameplay.  Other components may hook
// into this to send off analytics at certain intervals.  User info contains
// the total number of minutes passed (YRDTimeTrackerMinutesPassedKey) and the
// time played (YRDTimeTrackerTimePlayedKey).
extern NSString *YRDTimeTrackerMinutePassedNotification;
// Number of minutes user has played for.  Should be used for things like sending
// statistics every X minutes.
extern NSString *YRDTimeTrackerMinutesPassedKey;
// Time played in seconds.  More accurate than [minutes passed] * 60.0, should be
// used when a stat like currency per minute needs to be calculated
extern NSString *YRDTimeTrackerTimePlayedKey;


@interface YRDTimeTracker : NSObject

@end
