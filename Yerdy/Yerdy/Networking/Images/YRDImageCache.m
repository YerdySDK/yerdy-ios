//
//  YRDImageCache.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-19.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDImageCache.h"
#import "YRDImageResponseHandler.h"
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:)
												 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	
	return self;
}

- (void)loadImageAtURL:(NSURL *)URL completionHandler:(YRDImageLoadHandler)completionHandler
{
	if (completionHandler == NULL)
		completionHandler = ^(UIImage *image) {};
	
	if (_images[URL]) {
		completionHandler(_images[URL]);
		return;
	}
	
	if (_liveHandlers[URL]) {
		[_liveHandlers[URL] addObject:(id)completionHandler];
		return;
	}
	
	_liveHandlers[URL] = [NSMutableArray arrayWithObject:(id)completionHandler];
	
	YRDRequest *request = [[YRDRequest alloc] initWithURL:URL];
	request.responseHandler = [[YRDImageResponseHandler alloc] init];
	[YRDURLConnection sendRequest:request completionHandler:^(id response, NSError *error) {
		NSArray *handlers = _liveHandlers[URL];
		for (YRDImageLoadHandler handler in handlers) {
			handler(response);
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
