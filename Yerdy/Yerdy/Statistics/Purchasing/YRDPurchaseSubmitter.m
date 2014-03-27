//
//  YRDPurchaseSubmitter.m
//  Yerdy
//
//  Created by Darren Clark on 2014-03-07.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDPurchaseSubmitter.h"
#import "YRDConstants.h"
#import "YRDDataStore.h"
#import "YRDLog.h"
#import "YRDPaths.h"
#import "YRDReachability.h"
#import "YRDTrackPurchaseRequest.h"
#import "YRDTrackPurchaseResponse.h"
#import "YRDURLConnection.h"

static const int MIN_SLOTS = 1; /* 2^3 =  8 * slot time */
static const int MAX_SLOTS = 5; /* 2^10 = 1024 * slot time */
static const int BASE_FACTOR = 8;
static const int MAX_RETRIES = 6; /* after this many retries, stop*/
static const double SLOT_TIME = 1.f; /* 1 second slot time */


@interface YRDPurchaseSubmitter ()
{
	YRDTrackPurchaseRequest *_currentRequest;
	NSMutableArray *_requests;
	
	int _currentSlot;
}
@end


@implementation YRDPurchaseSubmitter

// Use an operation queue to handle synchronizing ourselves to disk on a background thread
// (it's important this happens serially so that we don't lose data)
+ (NSOperationQueue *)operationQueue
{
	static NSOperationQueue *queue = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		queue = [[NSOperationQueue alloc] init];
		queue.maxConcurrentOperationCount = 1;
	});
	
	return queue;
}

+ (NSString *)filePath
{
	return [[YRDPaths dataFilesDirectory] stringByAppendingPathComponent:@"purchases.dat"];
}

+ (YRDPurchaseSubmitter *)loadFromDisk
{
	@try {
		YRDPurchaseSubmitter *fromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
		if (fromDisk)
			return fromDisk;
		else
			return [[YRDPurchaseSubmitter alloc] init];
	} @catch (...) {
		return [[YRDPurchaseSubmitter alloc] init];
	}
}


- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_requests = [[NSMutableArray alloc] init];
	_currentSlot = 1;
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (!self)
		return nil;
	
	_requests = [[aDecoder decodeObjectForKey:@"requests"] mutableCopy];
	if (!_requests)
		_requests = [[NSMutableArray alloc] init];
	
	_currentSlot = 1;
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if (_requests) [aCoder encodeObject:_requests forKey:@"requests"];
}

- (void)addRequest:(YRDTrackPurchaseRequest *)request
{
	[_requests addObject:request];
	[self synchronize];
	
	[self uploadIfNeeded];
}

- (void)uploadIfNeeded
{
	if (_currentRequest || _requests.count == 0 || ![YRDReachability internetReachable])
		return;
	
	_currentRequest = _requests[0];
	
	[YRDURLConnection sendRequest:_currentRequest completionHandler:^(YRDTrackPurchaseResponse *response, NSError *error) {
		BOOL retry = NO;
		
		if (error && [error.domain isEqualToString:YRDErrorDomain]) {
			if (error.code == 401 || error.code == 403) {
				YRDError(@"trackPurchase - likely invalid publisher key/secret (HTTP status code %ld)", (long)error.code);
			} else if (error.code == 402) {
				YRDError(@"trackPurchase - missing receipt/invalid purchase (HTTP status code %ld)", (long)error.code);
			} else if (error.code == 501) {
				YRDError(@"trackPurchase - invalid/unsupported API version (HTTP status code %ld)", (long)error.code);
			} else {
				YRDError(@"trackPurchase - retry, other status code: (HTTP status code %ld)", (long)error.code);
				retry = YES;
			}
		} else if (error) {
			YRDError(@"trackPurchase - retry, generic error: %@", error);
			retry = YES;
		} else if (response.result == YRDTrackPurchaseResultServerError) {
			YRDError(@"trackPurchase - retry, server error: %@", error);
			retry = YES;
		}
		
		if (response.result == YRDTrackPurchaseResultSuccess) {
			[[YRDDataStore sharedDataStore] setObject:@0 forKey:YRDItemsPurchasedSinceInAppDefaultsKey];
		}
		
		YRDDebug(@"trackPurchase result: %d", response.result);
		
		// Schedule next uploads
		if (!retry) {
			[_requests removeObject:_currentRequest];
			[self synchronize];
			
			[self performSelector:@selector(uploadIfNeeded) withObject:nil afterDelay:5.0];
			_currentSlot = MIN_SLOTS;
		} else {
			double nextRetry = SLOT_TIME * powf(BASE_FACTOR, _currentSlot);
			_currentSlot = _currentSlot + 1;
			if (_currentSlot > MAX_SLOTS) _currentSlot = MAX_SLOTS;
			if (_currentSlot < MIN_SLOTS) _currentSlot = MIN_SLOTS;
			
			[NSObject cancelPreviousPerformRequestsWithTarget:self];
			
			if (_currentSlot <= MAX_RETRIES) {
				[self performSelector:@selector(uploadIfNeeded) withObject:nil afterDelay:nextRetry];
			}
		}
		
		_currentRequest = nil;
	}];
}

- (void)synchronize
{
	[[[self class] operationQueue] addOperationWithBlock:^{
		@try {
			[NSKeyedArchiver archiveRootObject:self toFile:[[self class] filePath]];
		} @catch (...) {
			// do nothing...
		}
	}];
}

@end
