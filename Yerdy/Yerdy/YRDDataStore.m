//
//  YRDDataStore.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-24.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDDataStore.h"
#import "YRDLog.h"
#import "YRDPaths.h"

#import <UIKit/UIKit.h>


@interface YRDDataStore ()
{
	NSMutableDictionary *_values;
	BOOL _dirty;
}
@end


@implementation YRDDataStore

+ (instancetype)sharedDataStore
{
	static YRDDataStore *instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}

+ (NSString *)filePath
{
	return [[YRDPaths dataFilesDirectory] stringByAppendingPathComponent:@"dataStore.dat"];
}

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	if (![self load])
		_values = [NSMutableDictionary dictionary];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizeNow)
												 name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizeNow)
												 name:UIApplicationWillTerminateNotification object:nil];
	
	return self;
}

#pragma mark - Saving/loading

- (BOOL)load
{
	NSData *data = [NSData dataWithContentsOfFile:[[self class] filePath]];
	if (!data)
		return NO;
	
	NSError *error;
	_values = [NSPropertyListSerialization propertyListWithData:data
														options:NSPropertyListMutableContainers
														 format:NULL
														  error:&error];
	if (_values == nil) {
		YRDError(@"Failed to load data store at %@: %@", [[self class] filePath], error);
		return NO;
	} else {
		return YES;
	}
}

- (void)synchronize
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[self synchronizeInternal];
	});
}

- (void)synchronizeNow
{
	[self synchronizeInternal];
}

- (void)synchronizeInternal
{
	@synchronized (self) {
		if (_dirty) {
			NSError *error;
			NSData *data = [NSPropertyListSerialization dataWithPropertyList:_values
																	  format:NSPropertyListBinaryFormat_v1_0
																	 options:0
																	   error:&error];
			if (!data) {
				YRDError(@"Failed to serialize data store to binary data: %@", error);
				return;
			}
			
			BOOL success = [data writeToFile:[[self class] filePath]
									 options:0
									   error:&error];
			if (!success) {
				YRDError(@"Failed to write data store to file at %@: %@", [[self class] filePath], error);
				return;
			}
			
			_dirty = NO;
		}
	}
}

#pragma mark - Generic setter/getters

- (id)objectForKey:(NSString *)key
{
	@synchronized (self) {
		return _values[key];
	}
}

- (void)setObject:(id)value forKey:(NSString *)key
{	
	@synchronized (self) {
		_dirty = YES;
		_values[key] = value;
	}
}

- (void)removeObjectForKey:(NSString *)key
{
	@synchronized (self) {
		_dirty = YES;
		[_values removeObjectForKey:key];
	}
}

#pragma mark - Type specific getters

- (id)objectForKey:(NSString *)key class:(Class)class
{
	id object = [self objectForKey:key];
	if (object && ![object isKindOfClass:class])
		object = nil;
	return object;
}

- (NSString *)stringForKey:(NSString *)key
{
	return [self objectForKey:key class:[NSString class]];
}

- (NSArray *)arrayForKey:(NSString *)key
{
	return [self objectForKey:key class:[NSArray class]];
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
	return [self objectForKey:key class:[NSDictionary class]];
}

- (NSData *)dataForKey:(NSString *)key
{
	return [self objectForKey:key class:[NSData class]];
}

- (NSInteger)integerForKey:(NSString *)key
{
	return [[self objectForKey:key class:[NSNumber class]] integerValue];
}

- (float)floatForKey:(NSString *)key
{
	return [[self objectForKey:key class:[NSNumber class]] floatValue];
}

- (double)doubleForKey:(NSString *)key
{
	return [[self objectForKey:key class:[NSNumber class]] doubleValue];
}

- (BOOL)boolForKey:(NSString *)key
{
	return [[self objectForKey:key class:[NSNumber class]] boolValue];
}

#pragma mark - Type specific setters

- (void)setInteger:(NSInteger)value forKey:(NSString *)key
{
	[self setObject:@(value) forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString *)key
{
	[self setObject:@(value) forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString *)key
{
	[self setObject:@(value) forKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key
{
	[self setObject:@(value) forKey:key];
}

@end
