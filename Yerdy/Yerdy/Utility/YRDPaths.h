//
//  YRDPaths.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRDPaths : NSObject

// Path to an appropriate place to store data files Yerdy
// Returns 'nil' if the directory could not be found/created
+ (NSString *)dataFilesDirectory;

@end
