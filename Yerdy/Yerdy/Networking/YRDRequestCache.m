//
//  YRDRequestCache.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDRequestCache.h"
#import "YRDPaths.h"
#import "YRDLog.h"


@interface YRDRequestCache ()
{
	// TODO: Verify NSFileManager is thread safe!
	NSFileManager *_fileManager;
	NSString *_directoryPath;
	
	// Access to either _cachedRequestIds and/or _reservedRequestIds MUST be
	// @synchronized on _requestIdSyncObject
	NSObject *_requestIdSyncObject;
	NSMutableArray *_cachedRequestIds;
	NSMutableSet *_reservedRequestIds;
}
@end


@implementation YRDRequestCache

+ (instancetype)sharedCache
{
	static YRDRequestCache *instance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_fileManager = [[NSFileManager alloc] init];
	
	if (![self setupDirectory])
		return nil;
	
	_cachedRequestIds = [[_fileManager contentsAtPath:_directoryPath] mutableCopy];
	if (!_cachedRequestIds)
		return nil;
	
	_reservedRequestIds = [NSMutableSet set];
	_requestIdSyncObject = [[NSObject alloc] init];
	
	return self;
}

- (BOOL)setupDirectory
{
	_directoryPath = [[YRDPaths dataFilesDirectory] stringByAppendingPathComponent:@"Requests"];
	if (!_directoryPath) {
		return NO;
	}
	
	NSError *error;
	BOOL success = [_fileManager createDirectoryAtPath:_directoryPath withIntermediateDirectories:YES
											attributes:@{} error:&error];
	
	if (!success) {
		YRDError(@"Failed to create requests cache directory (%@): %@", _directoryPath, error);
	}
	
	return success;
}

- (dispatch_queue_t)dispatchQueue
{
	return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
}

- (void)storeRequest:(YRDRequest *)request
{
	if (!request)
		return;
	
	dispatch_async([self dispatchQueue], ^{
		// generate a request ID in the format of "[timestamp].[suffix]" where suffix is an integer
		// that is incremented until a unique id is found
		long long int timestamp = (long long int)round([[NSDate date] timeIntervalSince1970]);
		NSString *requestId = nil;
		
		// Get a unique request ID
		@synchronized (_requestIdSyncObject) {
			int suffix = 0;
			
			requestId = [NSString stringWithFormat:@"%lld.%d", timestamp, suffix];
			while ([_cachedRequestIds containsObject:requestId] || [_reservedRequestIds containsObject:requestId])
				requestId = [NSString stringWithFormat:@"%lld.%d", timestamp, ++suffix];
			
			[_reservedRequestIds addObject:requestId];
		}
		
		// Store the request
		BOOL success = NO;
		@try {
			NSString *filePath = [_directoryPath stringByAppendingPathComponent:requestId];
			success = [NSKeyedArchiver archiveRootObject:request toFile:filePath];
		} @catch (...) {
			success = NO;
		}
		
		// Updated the request ID lists
		if (success) {
			@synchronized (_requestIdSyncObject) {
				[_reservedRequestIds removeObject:requestId];
				
				NSUInteger insertAt = 0;
				while (insertAt < _cachedRequestIds.count)
					if ([requestId compare:_cachedRequestIds[insertAt++] options:NSNumericSearch] == NSOrderedDescending)
						break;
				
				[_cachedRequestIds insertObject:requestId atIndex:0];
			}
		}
	});
}

- (BOOL)retrieveRequest:(YRDRequest * __autoreleasing *)outRequest
			  requestId:(NSString * __autoreleasing *)outRequestId
{
	@synchronized (_requestIdSyncObject) {
		NSString *requestId = _cachedRequestIds.firstObject;
		
		if (!requestId)
			return NO;
		
		//YRDRequest *request
	}
	return NO;
}

- (BOOL)retrieveRequest:(YRDRequest * __autoreleasing *)outRequest
			  requestId:(NSString * __autoreleasing *)outRequestId
		 afterRequestId:(NSInteger)after
{
	return NO;
}

- (void)removeRequestId:(NSString *)requestId
{
	if (!requestId)
		return;
	
	@synchronized (_requestIdSyncObject) {
		[_cachedRequestIds removeObject:requestId];
	}
	
	dispatch_async([self dispatchQueue], ^{
		NSString *path = [_directoryPath stringByAppendingPathComponent:requestId];
		NSError *error;
		
		if (![_fileManager removeItemAtPath:path error:&error]) {
			YRDError(@"Unable to remove cached request at '%@': %@", path, error);
		}
	});
}

@end
