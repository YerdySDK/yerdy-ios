//
//  YRDJSONType.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YRDJSONType <NSObject>
@required

// Should return a mapping of JSON key -> ObjC property name
+ (NSDictionary *)jsonMappings;

@optional

// - Optionally, per JSON key conversions can be used to convert the
//   input JSON value to a new value.
// - Should return a mapping of JSON key -> id(^)(id input)
// - Must return an NSString or NSNumber or nil
+ (NSDictionary *)jsonTypeConversions;

@end
