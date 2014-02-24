//
//  YRDJSONResponseHandler.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDJSONResponseHandler.h"
#import "YRDConstants.h"
#import "YRDLog.h"


@interface YRDJSONResponseHandler ()
{
	Class _objectType;
	BOOL _isArray;
	NSString *_rootKey;
}
@end


@implementation YRDJSONResponseHandler

- (id)initWithObjectType:(Class<YRDJSONType>)klass
{
	return [self initWithObjectType:klass rootKey:nil];
}

- (id)initWithArrayOfObjectType:(Class<YRDJSONType>)klass
{
	return [self initWithArrayOfObjectType:klass rootKey:nil];
}

- (id)initWithObjectType:(Class<YRDJSONType>)klass rootKey:(NSString *)rootKey
{
	self = [super init];
	if (!self)
		return nil;
	
	_objectType = klass;
	_rootKey = rootKey;
	_isArray = NO;
	
	return self;
}

- (id)initWithArrayOfObjectType:(Class<YRDJSONType>)klass rootKey:(NSString *)rootKey
{
	self = [super init];
	if (!self)
		return nil;
	
	_objectType = klass;
	_rootKey = rootKey;
	_isArray = YES;
	
	return self;
}

- (id)processResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)errorOut
{
	NSError *error;
	id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	
	if (json == nil) {
		if (errorOut) *errorOut = error;
		return nil;
	}
	
	// Depending on the call, the object may be in the value of '_rootKey'
	if ([json isKindOfClass:[NSDictionary class]] && json[_rootKey] != nil) {
		json = json[_rootKey];
	}
	
	if (_isArray && ![json isKindOfClass:[NSArray class]]) {
		if (errorOut) *errorOut = [self errorWithFormat:@"Expecting NSArray, but root object was %@", [json class]];
		return nil;
	} else if (!_isArray && ![json isKindOfClass:[NSDictionary class]]) {
		if (errorOut) *errorOut = [self errorWithFormat:@"Expecting NSDictionary, but root object was %@", [json class]];
		return nil;
	}
	
	@try {
		if (_isArray) {
			NSMutableArray *results = [NSMutableArray arrayWithCapacity:[json count]];
			for (id item in json) {
				// verify input JSON is NSDictionary
				if (![item isKindOfClass:[NSDictionary class]]) {
					if (errorOut) *errorOut = [self errorWithFormat:@"Array item was expecting NSDictionary, but object was %@", [item class]];
					return nil;
				}
				
				// try building the object
				id object = [self buildObjectOfType:_objectType fromDictionary:item];
				if (object == nil) {
					if (errorOut) *errorOut = [self errorWithFormat:@"Failed to build JSON object of type '%@'", _objectType];
					return nil;
				}
				[results addObject:object];
			}
			return results;
		} else {
			id object = [self buildObjectOfType:_objectType fromDictionary:json];
			if (object == nil) {
				if (errorOut) *errorOut = [self errorWithFormat:@"Failed to build JSON object of type '%@'", _objectType];
				return nil;
			}
			return object;
		}
	} @catch (NSException *ex) {
		if (errorOut) *errorOut = [self errorWithFormat:@"JSON parsing failed with exception: %@", ex];
		return nil;
	}
}

- (id)buildObjectOfType:(Class<YRDJSONType>)type fromDictionary:(NSDictionary *)dictionary
{
	NSDictionary *jsonMapping = [type jsonMappings];
	NSDictionary *jsonTypeConversions =
		[(id)type respondsToSelector:@selector(jsonTypeConversions)] ? [type jsonTypeConversions] : nil;
	
	id object = [[(Class)type alloc] init];
	
	for (NSString *key in dictionary) {
		NSString *propertyName = jsonMapping[key];
		if (!propertyName) {
			YRDDebug(@"Mapping not found on '%@' for JSON key '%@'", type, key);
			continue;
		}
		
		id value = dictionary[key];
		if ([value isKindOfClass:[NSNull class]])
			value = nil;
		
		id(^conversion)(id) = jsonTypeConversions[key];
		if (conversion) {
			// use custom conversion block
			value = conversion(value);
		} else {
			// validate we got a decent value from the server
			if (value != nil && (![value isKindOfClass:[NSString class]] && ![value isKindOfClass:[NSNumber class]])) {
				YRDDebug(@"Found unexpected JSON value for %@.%@: %@ (%@)", type, propertyName, value, [value class]);
				return nil;
			}
		}
		
		[object setValue:value forKey:propertyName];
	}
	
	return object;
}

- (NSError *)errorWithFormat:(NSString *)fmt, ... NS_FORMAT_FUNCTION(1,2);
{
	va_list ap;
	va_start(ap, fmt);
	NSString *str = [[NSString alloc] initWithFormat:fmt arguments:ap];
	va_end(ap);
	
	NSDictionary *userInfo = str != nil ? @{ NSLocalizedDescriptionKey : str } : nil;
	return [NSError errorWithDomain:YRDErrorDomain code:YRDJSONError userInfo:userInfo];
}

@end
