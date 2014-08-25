//
//  YRDFeatureMasteryTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-08-23.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRDHistoryTracker, YRDLaunchTracker, YRDTimeTracker, YRDTrackCounterBatcher;


@interface YRDFeatureMasteryTracker : NSObject

- (id)initWithCounterBatcher:(YRDTrackCounterBatcher *)counterBatcher
			   launchTracker:(YRDLaunchTracker *)launchTracker
				 timeTracker:(YRDTimeTracker *)timeTracker
			  historyTracker:(YRDHistoryTracker *)historyTracker;

- (void)logFeatureUse:(NSString *)featureName;

- (void)setFeatureUsesForNovice:(int)novice amateur:(int)amateur master:(int)master;
- (void)setFeatureUsesForNovice:(int)novice amateur:(int)amateur master:(int)master forFeature:(NSString *)feature;

@end
