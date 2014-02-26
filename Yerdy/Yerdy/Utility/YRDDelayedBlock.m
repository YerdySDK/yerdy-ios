//
//  YRDDelayedBlock.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDDelayedBlock.h"

@interface YRDDelayedBlock ()
{
	// nil'd out once it has been called
	void(^_block)(void);
}
@end


@implementation YRDDelayedBlock

+ (instancetype)afterDelay:(NSTimeInterval)timeInterval runBlock:(void(^)(void))block
{
	NSAssert(timeInterval >= 0.0, @"timeInterval must be greater than or equal to 0.0");
	NSAssert(block != NULL, @"block must not be null");
	
	YRDDelayedBlock *retVal = [[self alloc] initWithBlock:block];
	[retVal scheduleWithDelay:timeInterval];
	return retVal;
}

- (id)initWithBlock:(void(^)(void))block
{
	self = [super init];
	if (!self)
		return nil;
	
	_block = block;
	
	return self;
}

- (void)scheduleWithDelay:(NSTimeInterval)timeInterval
{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		if (_block) {
			_block();
			_block = nil;
		}
	});
}

- (void)cancel
{
	_block = nil;
}

- (void)callNow
{
	_block();
	_block = nil;
}

@end
