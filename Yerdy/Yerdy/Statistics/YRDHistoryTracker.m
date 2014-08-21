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


static NSString *History_ScreenVisits = @"ScreenVisits",
				*History_ItemPurchases = @"ItemPurchases",
				*History_LastMessages = @"LastMessages",
				*History_LastProgressionCategories = @"LastProgressionCategories",
				*History_LastProgressionMilestones = @"LastPorgressionMilestones";

static const int MaxItemsToTrack = 3;


@implementation YRDHistoryTracker

- (NSArray *)lastScreenVisits
{
	return [self historyItemsForType:History_ScreenVisits];
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

- (void)addScreenVisit:(NSString *)screen
{
	if (screen == nil) {
		YRDWarn(@"[YRDHistoryTracker addScreenVisit:] - screen was nil");
		return;
	}
	[self addHistoryItem:screen forType:History_ScreenVisits];
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
