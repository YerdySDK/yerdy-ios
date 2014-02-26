//
//  YRDTimer.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-17.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// A weak referenced, repeating version of NSTimer.  Invalidates the timer when
// 'timerTarget' gets destroyed or when -invalidate is called

@protocol YRDTimerTarget;


@interface YRDTimer : NSObject

@property (nonatomic, weak, readonly) id<YRDTimerTarget> timerTarget;

// Designated initalizer.
//	interval - time interval to trigger timer on
//	target - a object implementing YRDTimerTarget
//	tolerance - See -[NSTimer setTolerance:] for details
//	startOffset - "skips" ahead this many seconds for the first firing of the timer (for
//		example, when interval = 60.0 & startOffset = 25.0, the timer would fire at
//		35 seconds, then every minute after that)
- (id)initWithTimeInterval:(NSTimeInterval)interval target:(__weak id<YRDTimerTarget>)target
				 tolerance:(NSTimeInterval)tolerance startOffset:(NSTimeInterval)startOffset;

// Defaults to no startOffset
- (id)initWithTimeInterval:(NSTimeInterval)interval target:(__weak id<YRDTimerTarget>)target
				 tolerance:(NSTimeInterval)tolerance;
// Defaults to 0 tolerance and no skipTime
- (id)initWithTimeInterval:(NSTimeInterval)interval target:(__weak id<YRDTimerTarget>)target;

// Cancel the timer.  (NOTE: The timer is automatically invalidated when 'timerTarget'
// is dealloced)
- (void)invalidate;

@end


@protocol YRDTimerTarget <NSObject>
@required
- (void)timerFired:(YRDTimer *)timer;
@end
