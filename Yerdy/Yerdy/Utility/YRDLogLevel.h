//
//  YRDLogLevel.h
//  Yerdy
//
//  Created by Darren Clark on 2014-03-26.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

/** Log level
 
 Each level includes the preceding levels as well (for example, YRDLogInfo will include
 YRDLogWarn and YRDLogError messages as well)
 
 */
typedef enum YRDLogLevel {
	/** Nothing will be logged by Yerdy
	 */
	YRDLogSilent = 0,
	
	/** Only errors will be logged
	 */
	YRDLogError,
	
	/** Warnings and errors will be logged
	 */
	YRDLogWarn,
	
	/** Info messages, warnings, and errors will be logged
	 */
	YRDLogInfo,
	
	/** Debug and info messages, warnings, and errors will be logged
	 */
	YRDLogDebug,
} YRDLogLevel;
