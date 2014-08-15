//
//  YRDNotificationDispatcher.m
//  Yerdy
//
//  Created by Darren Clark on 2014-08-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDNotificationDispatcher.h"
#import "YRDNotificationObserverCollection.h"


@interface YRDNotificationDispatcher ()
{
	NSMutableDictionary *_observers; // notification name -> YRDNotificationObserverCollection
}
@end


@implementation YRDNotificationDispatcher

+ (instancetype)sharedDispatcher
{
	static YRDNotificationDispatcher *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	return instance;
}


- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_observers = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void)dispatchNotification:(NSNotification *)notification
{
	void *nilValue = 0;
	
	YRDNotificationObserverCollection *collection = _observers[notification.name];
	NSArray *invocations = [collection invocationsOrderedByPriority];
	
	for (NSInvocation *invocation in invocations) {
		NSUInteger numArgs = invocation.methodSignature.numberOfArguments;
		if (numArgs > 2)
			[invocation setArgument:&notification atIndex:2];
		
		[invocation invoke];
		
		if (numArgs > 2)
			[invocation setArgument:&nilValue atIndex:2];
	}
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName
{
	[self addObserver:observer selector:aSelector name:aName priority:0];
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName priority:(int)priority
{
	YRDNotificationObserverCollection *observers = _observers[aName];
	if (!observers) {
		observers = _observers[aName] = [[YRDNotificationObserverCollection alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dispatchNotification:) name:aName object:nil];
	}
	
	NSMethodSignature *methodSig = [observer methodSignatureForSelector:aSelector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
	invocation.target = observer;
	invocation.selector = aSelector;
	
	[observers addInvocation:invocation withPriority:priority];
}

- (void)removeObserver:(id)observer name:(NSString *)notificationName
{
	[_observers[notificationName] removeInvocationsWithTarget:observer];
}

- (void)removeObserver:(id)observer
{
	for (YRDNotificationObserverCollection *observers in _observers.allValues) {
		[observers removeInvocationsWithTarget:observer];
	}
}

@end
