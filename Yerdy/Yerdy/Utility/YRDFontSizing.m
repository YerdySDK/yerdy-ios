//
//  YRDFontSizing.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-18.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDFontSizing.h"
#import "YRDConstants.h"

@implementation YRDFontSizing

+ (CGSize)sizeForString:(NSString *)string font:(UIFont *)font
{
    return [string sizeWithAttributes:@{ NSFontAttributeName : font }];
}

+ (CGSize)sizeForString:(NSString *)string font:(UIFont *)font
				maxSize:(CGSize)maxSize lineBreakMode:(NSLineBreakMode)lineBreakMode
{
	// iOS 7+
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:string];
	[textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [textStorage length])];
		
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
		
	NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:maxSize];
	textContainer.lineBreakMode = lineBreakMode;
	textContainer.lineFragmentPadding = 0;
		
	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];
	return [layoutManager usedRectForTextContainer:textContainer].size;
}

@end
