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

@end
