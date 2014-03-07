//
//  YRDCounterEvent.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-06.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDCounterEvent.h"
#import "YRDLog.h"

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
	_name = [name copy];
	
	_idx = [@{ name : value } mutableCopy];
	_mod = [@{ name : @(increment) } mutableCopy];
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	YRDCounterEvent *copy = [[[self class] alloc] init];
	if (!copy)
		return nil;
	
	copy->_type = _type;
	copy->_name = _name;
	copy->_idx = [_idx mutableCopy];
	copy->_mod = [_mod mutableCopy];
	
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

- (void)incrementParameter:(NSString *)param byAmount:(NSUInteger)increment
{
	if (!_idx[param]) {
		YRDError(@"Attempting to increment non-existent parameter: %@", param);
		return;
	}
	_mod[param] = @([_mod[param] integerValue] + increment);
}

- (void)removeParameter:(NSString *)param
{
	[_idx removeObjectForKey:param];
	[_mod removeObjectForKey:param];
}

- (NSArray *)parameterNames
{
	return _idx.allKeys;
}

- (NSString *)valueForParameter:(NSString *)param
{
	return _idx[param];
}

- (NSUInteger)incrementForParameter:(NSString *)param
{
	return [_mod[param] unsignedIntegerValue];
}

@end
