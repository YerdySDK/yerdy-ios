//
//  Yerdy.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YerdyDelegate.h"

@interface Yerdy : NSObject

+ (instancetype)startWithPublisherKey:(NSString *)key;
+ (instancetype)sharedYerdy;

@property (nonatomic, weak) id<YerdyDelegate> delegate;


- (BOOL)messageAvailable:(NSString *)placement;

@end
