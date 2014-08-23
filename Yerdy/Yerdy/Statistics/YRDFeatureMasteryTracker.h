//
//  YRDFeatureMasteryTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-08-23.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRDLaunchTracker, YRDTimeTracker, YRDTrackCounterBatcher;


@interface YRDFeatureMasteryTracker : NSObject

- (id)initWithCounterBatcher:(YRDTrackCounterBatcher *)counterBatcher
			   launchTracker:(YRDLaunchTracker *)launchTracker
				 timeTracker:(YRDTimeTracker *)timeTracker;

- (void)logFeatureUse:(NSString *)featureName;

@end
