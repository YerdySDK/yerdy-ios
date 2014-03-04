//
//  YRDImageCache.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-19.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <UIKit/UIKit.h>

// If load failed, the UIImage will be nil
typedef void(^YRDImageLoadHandler)(UIImage *);


@interface YRDImageCache : NSObject

+ (YRDImageCache *)sharedCache;

// Total number of active requests
@property (nonatomic, readonly) NSUInteger numberOfActiveRequests;

// Loads the image at 'URL' (from the web or from a local cached copy).  'completionHandler'
// *may* be called before this method returns (when a cached copy is available), so make sure
// to take that into consideration.
- (void)loadImageAtURL:(NSURL *)URL completionHandler:(YRDImageLoadHandler)completionHandler;

@end
