//
//  YRDCounterEvent.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum YRDCounterType {
	YRDCounterTypeCustom = 0,	// custom events (custom events from app)
	YRDCounterTypeTime = 1,		// time based events (tracked internally by Yerdy)
	YRDCounterTypePlayer = 2,	// player progression events (tracked internally by Yerdy)
} YRDCounterType;


@interface YRDCounterEvent : NSObject <NSCopying>

// Values for services
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) YRDCounterType type;
@property (nonatomic, readonly) NSDictionary *idx;
@property (nonatomic, readonly) NSDictionary *mod;

// Creation
- (id)initWithType:(YRDCounterType)type name:(NSString *)name value:(NSString *)value;
- (id)initWithType:(YRDCounterType)type name:(NSString *)name value:(NSString *)value increment:(NSUInteger)increment;

// Modifying parameters
- (void)setValue:(NSString *)value forParameter:(NSString *)param;
- (void)setValue:(NSString *)value increment:(NSUInteger)increment forParameter:(NSString *)param;

- (void)incrementParameter:(NSString *)param byAmount:(NSUInteger)increment;

- (void)removeParameter:(NSString *)param;

// Querying parameters
@property (nonatomic, readonly) NSArray *parameterNames;

// Returns nil if parameter not set
- (NSString *)valueForParameter:(NSString *)param;
// Undefined behaviour if parameter not set (check if it exists with -parameterNames or -valueForParameter: first)
- (NSUInteger)incrementForParameter:(NSString *)param;

@end
