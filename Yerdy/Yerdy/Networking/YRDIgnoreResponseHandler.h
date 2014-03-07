//
//  YRDIgnoreResponseHandler.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-07.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDResponseHandler.h"

// Ignores the response returned from the server (for fire & forget requests)
// Always returns @YES and no error

@interface YRDIgnoreResponseHandler : YRDResponseHandler

@end
