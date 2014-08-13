//
//  YRDProgressionTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRDCurrencyTracker, YRDLaunchTracker, YRDTimeTracker, YRDTrackCounterBatcher;


@interface YRDProgressionTracker : NSObject

- (id)initWithCurrencyTracker:(YRDCurrencyTracker *)currencyTracker launchTracker:(YRDLaunchTracker *)launchTracker
				  timeTracker:(YRDTimeTracker *)timeTracker counterBatcher:(YRDTrackCounterBatcher *)batcher;

- (void)startPlayerProgression:(NSString *)category initialMilestone:(NSString *)milestone;
- (void)logPlayerProgression:(NSString *)category milestone:(NSString *)milestone;

@end
