//
//  YRDUserType.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-21.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#pragma once


typedef enum YRDUserType {
	YRDUserTypeNone,	// user hasn't made any purchases
	YRDUserTypeCheat,	// user's last purchase was detected as invalid
	YRDUserTypePay,		// user's last purchase was detected as valid
} YRDUserType;
