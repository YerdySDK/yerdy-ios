//
//  YRDHistoryTracker.m
//  Yerdy
//
//  Created by Darren Clark on 2014-08-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDHistoryTracker.h"
#import "YRDConstants.h"
#import "YRDDataStore.h"
#import "YRDLog.h"


static NSString *History_FeatureUses = @"FeatureUses",
				*History_ItemPurchases = @"ItemPurchases",
				*History_LastMessages = @"LastMessages",
				*History_LastProgressionCategories = @"LastProgressionCategories",
				*History_LastProgressionMilestones = @"LastPorgressionMilestones",
				*History_FeatureNames = @"FeatureNames",
				*History_FeatureLevels = @"FeatureLevels";

static const int MaxItemsToTrack = 3;


@implementation YRDHistoryTracker

- (NSArray *)lastFeatureUses
{
	return [self historyItemsForType:History_FeatureUses];
}

- (NSArray *)lastItemPurchases
{
	return [self historyItemsForType:History_ItemPurchases];
}

- (NSArray *)lastMessages
{
	return [self historyItemsForType:History_LastMessages];
}

- (NSArray *)lastPlayerProgressionCategories
{
	return [self historyItemsForType:History_LastProgressionCategories];
}

- (NSArray *)lastPlayerProgressionMilestones
{
	return [self historyItemsForType:History_LastProgressionMilestones];
}

- (NSArray *)lastFeatureNames
{
	return [self historyItemsForType:History_FeatureNames];
}

- (NSArray *)lastFeatureLevels
{
	return [self historyItemsForType:History_FeatureLevels];
}

- (void)addFeatureUse:(NSString *)feature
{
	if (feature == nil) {
		YRDWarn(@"[YRDHistoryTracker addFeatureUse:] - feature was nil");
		return;
	}
	[self addHistoryItem:feature forType:History_FeatureUses];
}

- (void)addItemPurchase:(NSString *)item
{
	if (item == nil) {
		YRDWarn(@"[YRDHistoryTracker addItemPurchase:] - item was nil");
		return;
	}
	[self addHistoryItem:item forType:History_ItemPurchases];
}

- (void)addMessage:(NSString *)msgId
{
	if (msgId == nil) {
		YRDWarn(@"[YRDHistoryTracker addMessage:] - msgId was nil");
		return;
	}
	[self addHistoryItem:msgId forType:History_LastMessages];
}

- (void)addPlayerProgression:(NSString *)category milestone:(NSString *)milestone
{
	if (category == nil || milestone == nil) {
		YRDWarn(@"[YRDHistoryTracker addPlayerProgression:milestone:] - category or milestone was nil");
		return;
	}
	[self addHistoryItem:category forType:History_LastProgressionCategories];
	[self addHistoryItem:milestone forType:History_LastProgressionMilestones];
}

- (void)addFeature:(NSString *)feature level:(int)level
{
	if (feature == nil) {
		YRDWarn(@"[YRDHistoryTracker addFeature:level:] - feature was nil");
		return;
	}
	[self addHistoryItem:feature forType:History_FeatureNames];
	[self addHistoryItem:[NSString stringWithFormat:@"_%d", level] forType:History_FeatureLevels];
}

- (NSArray *)historyItemsForType:(NSString *)type
{
	NSString *key = [NSString stringWithFormat:YRDHistoryItemsKeyFormat, type];
	return [[YRDDataStore sharedDataStore] arrayForKey:key];
}

- (void)addHistoryItem:(NSString *)historyItem forType:(NSString *)type
{
	NSString *key = [NSString stringWithFormat:YRDHistoryItemsKeyFormat, type];
	NSArray *current = [[YRDDataStore sharedDataStore] arrayForKey:key];
	
	NSMutableArray *modified = current != nil ? [current mutableCopy] : [NSMutableArray array];
	
	[modified insertObject:historyItem atIndex:0];
	while (modified.count > MaxItemsToTrack)
		[modified removeLastObject];
	
	[[YRDDataStore sharedDataStore] setObject:modified forKey:key];
}

@end
