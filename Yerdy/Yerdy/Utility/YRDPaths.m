//
//  YRDPaths.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDPaths.h"
#import "YRDLog.h"

@implementation YRDPaths

+ (NSString *)dataFilesDirectory
{
	static NSString *path = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		if (paths.count == 0)
			return;
		
		NSString *yerdyPath = [paths[0] stringByAppendingPathComponent:@"yerdy"];
		
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		
		NSError *createError;
		BOOL success = [fileManager createDirectoryAtPath:yerdyPath withIntermediateDirectories:YES
											   attributes:@{} error:&createError];
		if (!success) {
			YRDError(@"Error creating data directory (%@): %@", yerdyPath, createError);
			return;
		}
		
		path = yerdyPath;
	});
	
	return path;
}

@end
