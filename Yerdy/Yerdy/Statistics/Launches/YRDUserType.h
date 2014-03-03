//
//  YRDUserType.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#pragma once


// Writtent to disk, make sure the underlying value of each enum value doesn't change
typedef enum YRDUserType {
	YRDUserTypeNone = 0,	// user hasn't made any purchases
	YRDUserTypeCheat = 1,	// user's last purchase was detected as invalid
	YRDUserTypePay = 2,		// user's last purchase was detected as valid
} YRDUserType;
