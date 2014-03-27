//
//  YRDRequestCache.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDRequestCache.h"
#import "YRDIgnoreResponseHandler.h"
#import "YRDLog.h"
#import "YRDPaths.h"
#import "YRDReachability.h"
#import "YRDURLConnection.h"


@interface YRDRequestCache ()
{
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
	
	NSError *error;
	_cachedRequestIds = [[_fileManager contentsOfDirectoryAtPath:_directoryPath error:&error] mutableCopy];
	if (!_cachedRequestIds) {
		YRDError(@"Error getting cached requests: %@", error);
		return nil;
	}
	
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

- (void)sendStoredRequests
{
	if ([YRDReachability internetReachable])
		[self performSelectorInBackground:@selector(sendStoredRequestsInBackground) withObject:nil];
}

- (void)sendStoredRequestsInBackground
{
	NSArray *cachedRequestIds = nil;
	@synchronized (_requestIdSyncObject) {
		cachedRequestIds = [_cachedRequestIds copy];
	}
	
	for (NSString *requestId in cachedRequestIds) {
		YRDRequest *request = nil;
		
		@synchronized (_requestIdSyncObject) {
			// ensure it is still around
			if ([_cachedRequestIds containsObject:requestId]) {
				[_cachedRequestIds removeObject:requestId];
				
				NSString *filePath = [_directoryPath stringByAppendingPathComponent:requestId];
				@try {
					request = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
				} @catch (...) {
					request = nil;
				} @finally {
					[_fileManager removeItemAtPath:filePath error:NULL];
				}
			}
		}
		
		if (request) {
			request.responseHandler = [[YRDIgnoreResponseHandler alloc] init];
			
			YRDURLConnection *conn = [[YRDURLConnection alloc] initWithRequest:request completionHandler:NULL];
			[conn sendSynchronously];
		}
	}
}

@end
