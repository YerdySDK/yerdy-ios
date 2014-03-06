//
//  YRDLaunchRequest.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-13.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDLaunchRequest.h"
#import "YRDJSONResponseHandler.h"
#import "YRDLaunchResponse.h"
#import "YRDUtil.h"

#import <UIKit/UIKit.h>

static NSString *Path = @"stats/launch.php";


@implementation YRDLaunchRequest

+ (instancetype)launchRequestWithToken:(NSData *)token
							  launches:(int)launches
							   crashes:(int)crashes
							  playtime:(NSTimeInterval)playtime
							  currency:(NSArray *)currency
						  screenVisits:(NSDictionary *)screenVisits
{
	NSDictionary *queryParameters = [self queryParametersForToken:token
														 launches:launches
														  crashes:crashes
														 playtime:playtime
														 currency:currency];
	
	NSDictionary *bodyParameters = nil;
	if (screenVisits.count > 0) {
		bodyParameters = [self bodyParametersForScreenVisits:screenVisits];
	}
	
	YRDLaunchRequest *request = [[self alloc] initWithPath:Path queryParameters:queryParameters bodyParameters:bodyParameters];
	request.responseHandler = [[YRDJSONResponseHandler alloc] initWithObjectType:[YRDLaunchResponse class] rootKey:@"@attributes"];
	return request;
}

+ (NSDictionary *)queryParametersForToken:(NSData *)token
								 launches:(int)launches
								  crashes:(int)crashes
								 playtime:(NSTimeInterval)playtime
								 currency:(NSArray *)currency
{
	// timezone string format: -700 for -7 hours, 300 for +3 hours, etc...
	NSTimeZone *timezone = [NSTimeZone localTimeZone];
	NSString *timezoneString = [NSString stringWithFormat:@"%04.0d", [timezone secondsFromGMT] / 36];
	
	UIDevice *device = [UIDevice currentDevice];
	NSString *os = [NSString stringWithFormat:@"%@ %@", device.systemName, device.systemVersion];
	
	NSLocale *locale = [NSLocale currentLocale];
	NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
	NSString *languageCode = [locale objectForKey:NSLocaleLanguageCode];
	
	NSString *currencyString = [currency componentsJoinedByString:@";"];
	
	return @{
		@"api" : @2,
		@"token" : YRDToString([YRDUtil base64String:token]),
		@"token_type" : @"apn",
		@"timezone" : YRDToString(timezoneString),
		@"type" : YRDToString(device.model),
		@"os" : YRDToString(os),
		@"country" : YRDToString(countryCode),
		@"language" : YRDToString(languageCode),
		@"launches" : @(launches),
		@"crashes" : @(crashes),
		@"playtime" : @((int)roundf(playtime)),
		@"currency" : currencyString,
	};
}

+ (NSDictionary *)bodyParametersForScreenVisits:(NSDictionary *)screenVisits
{
	NSMutableDictionary *bodyParameters = [NSMutableDictionary dictionary];
	for (NSString *screenName in screenVisits) {
		NSString *sanitizedName = [[screenName stringByReplacingOccurrencesOfString:@"[" withString:@" "]
								   stringByReplacingOccurrencesOfString:@"]" withString:@" "];
		
		NSString *paramName = [NSString stringWithFormat:@"nav[%@]", sanitizedName];
		bodyParameters[paramName] = screenVisits[screenName];
	}
	return bodyParameters;
}

@end
