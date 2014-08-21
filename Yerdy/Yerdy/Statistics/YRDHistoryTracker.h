//
//  YRDHistoryTracker.h
//  Yerdy
//
//  Created by Darren Clark on 2014-08-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Records the user's recent activities for submission with IAPs

@interface YRDHistoryTracker : NSObject

@property (nonatomic, readonly) NSArray *lastScreenVisits;
@property (nonatomic, readonly) NSArray *lastItemPurchases;
@property (nonatomic, readonly) NSArray *lastMessages;
@property (nonatomic, readonly) NSArray *lastPlayerProgressionCategories;
@property (nonatomic, readonly) NSArray *lastPlayerProgressionMilestones;

- (void)addScreenVisit:(NSString *)screen;
- (void)addItemPurchase:(NSString *)item;
- (void)addMessage:(NSString *)msgId;
- (void)addPlayerProgression:(NSString *)category milestone:(NSString *)milestone;

@end
