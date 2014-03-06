//
//  YRDScreenVisitTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-05.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRDScreenVisitTracker : NSObject

// dictionary mapping 'screen name' (NSString) -> '# of visits' (NSNumber)
@property (nonatomic, readonly) NSDictionary *loggedScreenVisits;

- (void)logScreenVisit:(NSString *)screenName;
- (void)reset;

@end
