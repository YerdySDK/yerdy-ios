//
//  YRDFontSizing.h
//  Yerdy
//
//  Created by Darren Clark on 2014-02-18.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YRDFontSizing : NSObject

// Uses slightly different methods based on the current iOS version

// For a single line of text
+ (CGSize)sizeForString:(NSString *)string font:(UIFont *)font;

// For multiline text
+ (CGSize)sizeForString:(NSString *)string font:(UIFont *)font
				maxSize:(CGSize)maxSize lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
