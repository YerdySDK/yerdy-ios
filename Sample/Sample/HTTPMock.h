//
//  HTTPMock.h
//  Sample
//
//  Created by Darren Clark on 2014-02-11.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPMock : NSURLProtocol

+ (void)enableWithPlist:(NSString *)name;

@end
