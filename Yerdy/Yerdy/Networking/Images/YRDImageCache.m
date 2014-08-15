//
//  YRDImageCache.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-19.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDImageCache.h"
#import "YRDImageResponseHandler.h"
#import "YRDNotificationDispatcher.h"
#import "YRDURLConnection.h"

#import <UIKit/UIKit.h>


static const NSUInteger MIN_DISK_CAPACITY = 1024 * 1024 * 16;	// 16 MB

@interface YRDImageCache ()
{
	// NSURL -> mutable array of YRDImageLoadHandler
	NSMutableDictionary *_liveHandlers;
	NSMutableDictionary *_images;
}
@end


@implementation YRDImageCache

+ (YRDImageCache *)sharedCache
{
	static YRDImageCache *instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[YRDImageCache alloc] init];
		
		NSURLCache *cache = [NSURLCache sharedURLCache];
		if (cache.diskCapacity < MIN_DISK_CAPACITY)
			cache.diskCapacity = MIN_DISK_CAPACITY;
	});
	
	return instance;
}

- (id)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_liveHandlers = [NSMutableDictionary dictionary];
	[[YRDNotificationDispatcher sharedDispatcher] addObserver:self selector:@selector(didReceiveMemoryWarning:)
														 name:UIApplicationDidReceiveMemoryWarningNotification];
	
	return self;
}

- (NSUInteger)numberOfActiveRequests
{
	return _liveHandlers.count;
}

- (void)loadImageAtURL:(NSURL *)URL completionHandler:(YRDImageLoadHandler)completionHandler
{
	// wrap it in a new block, so we have a unique block for every call to this method
	// (previously, if a user passed in the same URL & completionHandler it would crash)
	YRDImageLoadHandler innerHandler = ^(id image){
		if (completionHandler)
			completionHandler(image);
	};
	
	if (_images[URL]) {
		innerHandler(_images[URL]);
		return;
	}
	
	if (_liveHandlers[URL]) {
		[_liveHandlers[URL] addObject:(id)innerHandler];
		return;
	}
	
	_liveHandlers[URL] = [NSMutableArray arrayWithObject:(id)innerHandler];
	
	YRDRequest *request = [[YRDRequest alloc] initWithURL:URL];
	request.responseHandler = [[YRDImageResponseHandler alloc] init];
	[YRDURLConnection sendRequest:request completionHandler:^(id response, NSError *error) {
		if (response != nil)
			_images[URL] = response;
		
		// Since we may add new items to _liveHandlers[URL] as we are iterating it,
		// we run a while loop until we chew through all the items
		while ([_liveHandlers[URL] count] > 0) {
			NSArray *handlers = [_liveHandlers[URL] copy];
			for (YRDImageLoadHandler handler in handlers) {
				handler(response);
			}
			[_liveHandlers[URL] removeObjectsInArray:handlers];
		}
		[_liveHandlers removeObjectForKey:URL];
	}];
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
	// unload all images
	_images = [NSMutableDictionary dictionary];
}

@end
