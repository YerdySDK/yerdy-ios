//
//  Yerdy.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-03.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Yerdy : NSObject

+ (instancetype)startWithPublisherKey:(NSString *)key;
+ (instancetype)sharedYerdy;

- (BOOL)messageAvailable:(NSString *)placement;

@end
