//
//  YRDNotificationObserverCollection.h
//  Yerdy
//
//  Created by Darren Clark on 2014-08-14.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRDNotificationObserverCollection : NSObject

- (void)addInvocation:(NSInvocation *)invocation withPriority:(int)priority;
- (void)removeInvocationsWithTarget:(id)target;

- (NSArray *)invocationsOrderedByPriority;

@end
