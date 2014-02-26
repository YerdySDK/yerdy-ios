//
//  YRDJSONResponseHandler.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDResponseHandler.h"
#import "YRDJSONType.h"

@interface YRDJSONResponseHandler : YRDResponseHandler

- (id)initWithObjectType:(Class<YRDJSONType>)klass;
- (id)initWithArrayOfObjectType:(Class<YRDJSONType>)klass;

// If rootKey != nil, uses the value of that key to parse the JSON
- (id)initWithObjectType:(Class<YRDJSONType>)klass rootKey:(NSString *)rootKey;
- (id)initWithArrayOfObjectType:(Class<YRDJSONType>)klass rootKey:(NSString *)rootKey;

@end
