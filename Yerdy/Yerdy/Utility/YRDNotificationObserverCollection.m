//
//  YRDNotificationObserverCollection.m
//  Yerdy
//
//  Created by Darren Clark on 2014-08-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDNotificationObserverCollection.h"

@interface YRDNotificationObserverCollection ()
{
	// indexes match up between the 2 arrays (i.e. invocation at index 2 has it's
	// priority at index 2)
	NSMutableArray *_invocations;
	NSMutableArray *_priorities;
}
@end


@implementation YRDNotificationObserverCollection

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_invocations = [[NSMutableArray alloc] init];
	_priorities = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)addInvocation:(NSInvocation *)invocation withPriority:(int)priority
{
	// insert, sorted ascending
	NSUInteger insertIndex = [_priorities indexOfObjectPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop) {
		return priority < obj.intValue;
	}];
	
	if (insertIndex == NSNotFound) {
		insertIndex = _priorities.count;
	}
	
	[_invocations insertObject:invocation atIndex:insertIndex];
	[_priorities insertObject:@(priority) atIndex:insertIndex];
}

- (void)removeInvocationsWithTarget:(id)target
{
	NSIndexSet *indexes = [_invocations indexesOfObjectsPassingTest:^BOOL(NSInvocation *obj, NSUInteger idx, BOOL *stop) {
		return obj.target == target;
	}];
	
	[_invocations removeObjectsAtIndexes:indexes];
	[_priorities removeObjectsAtIndexes:indexes];
}

- (NSArray *)invocationsOrderedByPriority
{
	return _invocations;
}

@end
