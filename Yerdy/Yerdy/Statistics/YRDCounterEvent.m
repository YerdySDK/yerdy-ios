//
//  YRDCounterEvent.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDCounterEvent.h"

@interface YRDCounterEvent ()
{
	NSMutableDictionary *_idx;
	NSMutableDictionary *_mod;
}
@end

@implementation YRDCounterEvent

@synthesize idx = _idx;
@synthesize mod = _mod;

- (id)initWithType:(YRDCounterType)type name:(NSString *)name value:(NSString *)value
{
	return [self initWithType:type name:name value:value increment:1];
}

- (id)initWithType:(YRDCounterType)type name:(NSString *)name value:(NSString *)value increment:(NSUInteger)increment
{
	self = [super init];
	if (!self)
		return nil;

	_type = type;
	_name = name;
	
	_idx = [@{ name : value } mutableCopy];
	_mod = [@{ name : @(increment) } mutableCopy];
	
	return self;
}

- (void)setValue:(NSString *)value forParameter:(NSString *)param
{
	[self setValue:value increment:1 forParameter:param];
}

- (void)setValue:(NSString *)value increment:(NSUInteger)increment forParameter:(NSString *)param
{
	_idx[param] = value;
	_mod[param] = @(increment);
}

@end
