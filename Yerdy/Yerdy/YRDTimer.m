//
//  YRDTimer.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-17.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDTimer.h"
#import "YRDConstants.h"

@interface YRDTimer ()
{
	NSTimer *_timer;
	
	NSTimeInterval _timeInterval;
	NSTimeInterval _tolerance;
}
@end


@implementation YRDTimer

- (id)initWithTimeInterval:(NSTimeInterval)interval target:(__weak id<YRDTimerTarget>)target
				 tolerance:(NSTimeInterval)tolerance startOffset:(NSTimeInterval)startOffset
{
	self = [super init];
	if (!self)
		return nil;
	
	_timerTarget = target;
	_timeInterval = interval;
	
	if (startOffset != 0.0) {
		_timer = [NSTimer scheduledTimerWithTimeInterval:startOffset target:self
												selector:@selector(startOffsetPassed:)
												userInfo:nil repeats:NO];
	} else {
		[self scheduleMainTimer];
	}
	
	return self;
}

- (id)initWithTimeInterval:(NSTimeInterval)interval target:(__weak id<YRDTimerTarget>)target
				 tolerance:(NSTimeInterval)tolerance
{
	return [self initWithTimeInterval:interval target:target tolerance:tolerance startOffset:0.0];
}

- (id)initWithTimeInterval:(NSTimeInterval)interval target:(__weak id<YRDTimerTarget>)target
{
	return [self initWithTimeInterval:interval target:target tolerance:0.0 startOffset:0.0];
}

- (void)invalidate
{
	[_timer invalidate];
	_timer = nil;
}

- (void)scheduleMainTimer
{
	_timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self
											selector:@selector(timerTicked:)
											userInfo:nil repeats:YES];

#if YRD_COMPILING_FOR_IOS_7
	if (_tolerance != 0.0 && [_timer respondsToSelector:@selector(setTolerance:)])
		[_timer setTolerance:_tolerance];
#endif
	
}

- (void)timerTicked:(NSTimer *)timer
{
	[_timerTarget timerFired:self];
	if (_timerTarget == nil) {
		[_timer invalidate];
		_timer = nil;
	}
}

- (void)startOffsetPassed:(NSTimer *)timer
{
	[_timer invalidate];
	_timer = nil;
	
	[_timerTarget timerFired:self];
	if (_timerTarget != nil)
		[self scheduleMainTimer];
}

@end
