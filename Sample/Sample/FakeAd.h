//
//  FakeAd.h
//  Sample
//
//  Created by Darren Clark on 2014-05-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Fake ad for the purposes of testing ad requests/fills
// Randomly calls either the success/failure delegate when an ad is requested

@class FakeAd;

@protocol FakeAdDelegate <NSObject>
@optional
- (void)fakeAdFetchedAd:(FakeAd *)ad;
- (void)fakeAd:(FakeAd *)ad failedWithError:(NSError *)error;

- (void)fakeAdDismissed:(FakeAd *)ad;
@end


@interface FakeAd : NSObject

@property (nonatomic, weak) id<FakeAdDelegate> delegate;

- (void)requestAd;
- (void)showAd;

@end
