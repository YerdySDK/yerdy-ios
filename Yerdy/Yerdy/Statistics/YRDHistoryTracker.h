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

@property (nonatomic, readonly) NSArray *lastFeatureUses;
@property (nonatomic, readonly) NSArray *lastItemPurchases;
@property (nonatomic, readonly) NSArray *lastMessages;
@property (nonatomic, readonly) NSArray *lastPlayerProgressionCategories;
@property (nonatomic, readonly) NSArray *lastPlayerProgressionMilestones;
@property (nonatomic, readonly) NSArray *lastFeatureNames;
@property (nonatomic, readonly) NSArray *lastFeatureLevels;

- (void)addFeatureUse:(NSString *)feature;
- (void)addItemPurchase:(NSString *)item;
- (void)addMessage:(NSString *)msgId;
- (void)addPlayerProgression:(NSString *)category milestone:(NSString *)milestone;
- (void)addFeature:(NSString *)feature level:(int)level;

@end
