//
//  YRDScreenVisitTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-05.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRDHistoryTracker;


@interface YRDScreenVisitTracker : NSObject

- (id)initWithHistoryTracker:(YRDHistoryTracker *)historyTracker;

// dictionary mapping 'screen name' (NSString) -> '# of visits' (NSNumber)
@property (nonatomic, readonly) NSDictionary *loggedScreenVisits;

- (void)logScreenVisit:(NSString *)screenName;
- (void)reset;

@end
