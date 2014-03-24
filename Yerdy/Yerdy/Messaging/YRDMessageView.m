//
//  YRDMessageView.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-18.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDMessageView.h"
#import "YRDConstants.h"
#import "YRDMessageViewController.h"
#import "YRDMessage.h"
#import "YRDFontSizing.h"


typedef enum YRDButtonType {
	YRDButtonTypeCancel,
	YRDButtonTypeConfirm,
} YRDButtonType;


@interface YRDMessageView ()
{
	UIView *_contentContainer;
	
	UIImageView *_imageView;
	UIImageView *_watermarkImageView;
	
	UILabel *_titleLabel;
	UILabel *_messageLabel;
	UILabel *_expiryLabel;
	
	NSArray *_buttons;
}
@end


@implementation YRDMessageView

- (id)initWithViewController:(YRDMessageViewController *)viewController message:(YRDMessage *)message
{
    self = [super initWithFrame:CGRectZero];
    if (!self)
		return nil;
	
	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
	[self loadSubviewsForViewController:viewController message:message];
	
    return self;
}

#pragma mark - View Creation & Layout

- (void)loadSubviewsForViewController:(YRDMessageViewController *)viewController message:(YRDMessage *)message
{
	_contentContainer = [[UIView alloc] init];
	_contentContainer.backgroundColor = [self containerBackgroundColor:message];
	_contentContainer.opaque = YES;
	[self addSubview:_contentContainer];
	viewController.containerView = _contentContainer;
	
	_watermarkImageView = [[UIImageView alloc] init];
	_watermarkImageView.backgroundColor = [UIColor clearColor];
	_watermarkImageView.opaque = NO;
	_watermarkImageView.clipsToBounds = YES;
	[_contentContainer addSubview:_watermarkImageView];
	viewController.watermarkImageView = _watermarkImageView;
	
	_titleLabel = [[UILabel alloc] init];
	_titleLabel.text = message.messageTitle;
	_titleLabel.font = [UIFont boldSystemFontOfSize:16.0 * [self deviceScaleFactor]];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.textColor = [self textColor:message];
	[_contentContainer addSubview:_titleLabel];
	
	_messageLabel = [[UILabel alloc] init];
	_messageLabel.text = message.messageText;
	_messageLabel.font = [UIFont systemFontOfSize:14.0 * [self deviceScaleFactor]];
	_messageLabel.backgroundColor = [UIColor clearColor];
	_messageLabel.textColor = [self textColor:message];
	_messageLabel.numberOfLines = 0;
	_messageLabel.adjustsFontSizeToFitWidth = YES;
	const CGFloat minimumScaleFactor = 0.6;
#if YRD_COMPILING_FOR_IOS_7
	if ([_messageLabel respondsToSelector:@selector(setMinimumScaleFactor:)]) {
		_messageLabel.minimumScaleFactor = minimumScaleFactor;
	} else {
		_messageLabel.minimumFontSize = floorf(14.0*minimumScaleFactor);
	}
#else
	_messageLabel.minimumFontSize = floorf(14.0*minimumScaleFactor);
#endif
	[_contentContainer addSubview:_messageLabel];
	
	_expiryLabel = [[UILabel alloc] init];
	_expiryLabel.font = [UIFont boldSystemFontOfSize:12.0 * [self deviceScaleFactor]];
	_expiryLabel.text = [self expiryStringForDate:message.expiryDate];
	_expiryLabel.backgroundColor = [UIColor clearColor];
	_expiryLabel.textColor = [self expiryTextColor:message];
	_expiryLabel.textAlignment = UITextAlignmentCenter;
	[_contentContainer addSubview:_expiryLabel];
	
	_imageView = [[UIImageView alloc] init];
	_imageView.backgroundColor = [UIColor blackColor];
	[_contentContainer addSubview:_imageView];
	viewController.imageView = _imageView;
	
	NSMutableArray *buttons = [NSMutableArray array];
	if (message.confirmLabel.length > 0 && message.cancelLabel.length > 0) {
		UIButton *cancel = [self makeButtonOfType:YRDButtonTypeCancel forMessage:message];
		[cancel setTitle:message.cancelLabel forState:UIControlStateNormal];
		[cancel addTarget:viewController action:@selector(cancelTapped:) forControlEvents:UIControlEventTouchUpInside];
		[buttons addObject:cancel];
		
		viewController.cancelButton = cancel;
		
		UIButton *confirm = [self makeButtonOfType:YRDButtonTypeConfirm forMessage:message];
		[confirm setTitle:message.confirmLabel forState:UIControlStateNormal];
		[confirm addTarget:viewController action:@selector(confirmTapped:) forControlEvents:UIControlEventTouchUpInside];
		[buttons addObject:confirm];
	} else {
		BOOL isConfirm = message.confirmLabel.length > 0;
		// if we have a single button, always make it look like a confirm button,
		// even though it may be wired up to be a "cancel"/"view"
		UIButton *button = [self makeButtonOfType:YRDButtonTypeConfirm forMessage:message];
		
		NSString *title = isConfirm ? message.confirmLabel : message.cancelLabel;
		[button setTitle:title forState:UIControlStateNormal];
		
		SEL tappedSelector = isConfirm ? @selector(confirmTapped:) : @selector(cancelTapped:);
		[button addTarget:viewController action:tappedSelector forControlEvents:UIControlEventTouchUpInside];
		
		if (!isConfirm)
			viewController.cancelButton = button;
		
		[buttons addObject:button];
	}
	for (UIButton *button in buttons)
		[_contentContainer addSubview:button];
	_buttons = buttons;
}

- (void)layoutSubviews
{
	CGRect bounds = self.bounds;
	if (bounds.size.height > bounds.size.width) {
		[self layoutPortrait];
	} else {
		[self layoutLandscape];
	}
}

- (void)layoutPortrait
{
	CGRect bounds = self.bounds;
	CGRect containerBounds = CGRectMake(0.0, 0.0, [self shortDimension], [self longDimension]);
	CGPoint containerCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) + [self statusBarHeight]/2.0);
	
	_contentContainer.bounds = containerBounds;
	_contentContainer.center = containerCenter;
	
	CGFloat currentY = 0.0;
	
	_imageView.frame = CGRectMake(0.0, 0.0, [self shortDimension], [self shortDimension]);
	currentY = CGRectGetMaxY(_imageView.frame);
	currentY += [self padding];
	
	_watermarkImageView.frame = CGRectMake(0.0,
		CGRectGetMaxY(_imageView.frame),
		containerBounds.size.width,
		containerBounds.size.height - CGRectGetMaxY(_imageView.frame));
	
	CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font];
	_titleLabel.frame = CGRectMake([self padding], currentY,
								   containerBounds.size.width - [self padding] * 2.0,
								   size.height);
	currentY = CGRectGetMaxY(_titleLabel.frame);
	currentY += [self padding];
	
	CGFloat bottomContentY = containerBounds.size.height - [self buttonHeight] - [self padding] * 0.5;
	
	CGRect buttonsRect = CGRectMake(0.0, bottomContentY, containerBounds.size.width, [self buttonHeight]);
	[self layoutButtonsInRect:buttonsRect];
	
	if (_expiryLabel.text.length > 0) {
		CGSize expirySize = [YRDFontSizing sizeForString:_expiryLabel.text font:_expiryLabel.font];
		_expiryLabel.frame = CGRectMake([self padding], bottomContentY - [self padding] - expirySize.height,
										containerBounds.size.width - [self padding] * 2.0, expirySize.height);
		bottomContentY = _expiryLabel.frame.origin.y;
	}
	
	// Y value before buttons at bottom - currentY
	CGFloat bodyMaxHeight = (bottomContentY - [self padding]) - currentY;
	CGSize bodyMaxSize = CGSizeMake([self shortDimension] - [self padding] * 2.0, bodyMaxHeight);
	CGSize bodySize = [YRDFontSizing sizeForString:_messageLabel.text font:_messageLabel.font
										   maxSize:bodyMaxSize lineBreakMode:NSLineBreakByWordWrapping];
	_messageLabel.frame = CGRectMake([self padding], currentY, bodySize.width, bodySize.height);
}

- (void)layoutLandscape
{
	CGRect bounds = self.bounds;
	CGRect containerBounds = CGRectMake(0.0, 0.0, [self longDimension], [self shortDimension]);
	
	// old 3.5 inch iPhones are
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
		[UIScreen mainScreen].bounds.size.height < 568.0) {
		containerBounds.size.width += [self padding] * 4.0;
	}
	
	CGPoint containerCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) + [self statusBarHeight]/2.0);
	
	_contentContainer.bounds = containerBounds;
	_contentContainer.center = containerCenter;
		
	_imageView.frame = CGRectMake(0.0, 0.0, [self shortDimension], [self shortDimension]);
	
	_watermarkImageView.frame = CGRectMake(CGRectGetMaxX(_imageView.frame),
		0.0,
		containerBounds.size.width - CGRectGetMaxX(_imageView.frame),
		containerBounds.size.height);
	
	// the minimum X value for labels and stuff going on the right side of the image
	CGFloat leftX = CGRectGetMaxX(_imageView.frame) + [self padding];
	CGFloat currentY = [self padding];
	
	CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font];
	_titleLabel.frame = CGRectMake(leftX, currentY,
								   containerBounds.size.width - leftX - [self padding],
								   size.height);
	currentY = CGRectGetMaxY(_titleLabel.frame);
	currentY += [self padding];
	
	CGFloat bottomContentY = containerBounds.size.height - [self buttonHeight] - [self padding] * 0.5;
	
	CGRect buttonsRect = CGRectMake(leftX, bottomContentY, containerBounds.size.width - leftX - [self padding], [self buttonHeight]);
	[self layoutButtonsInRect:buttonsRect];
	
	
	if (_expiryLabel.text.length > 0) {
		CGSize expirySize = [YRDFontSizing sizeForString:_expiryLabel.text font:_expiryLabel.font];
		_expiryLabel.frame = CGRectMake(leftX, bottomContentY - [self padding] - expirySize.height,
										containerBounds.size.width - leftX - [self padding], expirySize.height);
		bottomContentY = _expiryLabel.frame.origin.y;
	}
	
	// Y value before buttons at bottom - currentY
	CGFloat bodyMaxHeight = (bottomContentY - [self padding]) - currentY;
	CGSize bodyMaxSize = CGSizeMake(containerBounds.size.width - leftX - [self padding], bodyMaxHeight);
	CGSize bodySize =[YRDFontSizing sizeForString:_messageLabel.text font:_messageLabel.font
										  maxSize:bodyMaxSize lineBreakMode:NSLineBreakByWordWrapping];
	_messageLabel.frame = CGRectMake(leftX, currentY, bodySize.width, bodySize.height);
	
}

- (void)layoutButtonsInRect:(CGRect)rect
{
	// width of buttons + padding
	CGFloat totalWidth = _buttons.count * [self buttonWidth] + [self padding] * (_buttons.count - 1);
	CGFloat centerX = CGRectGetMidX(rect);
	
	for (NSUInteger i = 0; i < _buttons.count; i++) {
		CGFloat x = centerX - totalWidth/2.0 + i * [self buttonWidth] + i * [self padding];
		CGFloat y = rect.origin.y;
		
		CGFloat centerX = x + [self buttonWidth] / 2.0;
		CGFloat centerY = y + [self buttonHeight] / 2.0;
		
		UIButton *button = _buttons[i];
		button.center = CGPointMake(centerX, centerY);
	}
}

#pragma mark - Button creation

- (UIButton *)makeButtonOfType:(YRDButtonType)buttonType forMessage:(YRDMessage *)message
{
	CGSize buttonSize = CGSizeMake([self buttonWidth], [self buttonHeight]);
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0 * [self deviceScaleFactor]];
	button.bounds = CGRectMake(0.0, 0.0, buttonSize.width, buttonSize.height);
	
	if (buttonType == YRDButtonTypeConfirm) {
		[button setTitleColor:[self confirmButtonTextColor:message] forState:UIControlStateNormal];
		
		UIImage *background = [self buttonBackgroundWithSize:buttonSize rectHeightRatio:0.9 color:[self confirmButtonColor:message]];
		[button setBackgroundImage:background forState:UIControlStateNormal];
	} else if (buttonType == YRDButtonTypeCancel) {
		[button setTitleColor:[self cancelButtonTextColor:message] forState:UIControlStateNormal];
		
		UIImage *background = [self buttonBackgroundWithSize:buttonSize rectHeightRatio:0.8 color:[self cancelButtonColor:message]];
		[button setBackgroundImage:background forState:UIControlStateNormal];
	}
	
	return button;
}

- (UIImage *)buttonBackgroundWithSize:(CGSize)size rectHeightRatio:(CGFloat)rectHeightRatio color:(UIColor *)color
{
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	
	[color setFill];
	
	CGFloat rectHeight = size.height * rectHeightRatio;
	CGRect rect = CGRectMake(0, size.height/2.0 - rectHeight/2.0, size.width, rectHeight);
	
	CGFloat cornerRadius = rectHeight * (1.0/3.0);
	// floorf & -1.0 required so that retina devices don't lose their mind when trying to render
	// the corner radii (comment out line and run on non-retina & retina device to see what I mean)
	cornerRadius = floorf(cornerRadius - 1.0);
	
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
	[path fill];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

#pragma mark - Expiry string

- (NSString *)expiryStringForDate:(NSDate *)expiryDate
{
	const int HOUR = 60 * 60;
	const int DAY = 24 * HOUR;
	
	if (!expiryDate)
		return nil;
	
	if ([expiryDate timeIntervalSinceNow] < 60 || [expiryDate timeIntervalSinceNow] > 30*DAY)
		return @"Expires soon!";
	
	int secondsLeft = (int)ABS([expiryDate timeIntervalSinceNow]);
	
	NSMutableString *retVal = [NSMutableString stringWithString:@"Expires in "];
	
	int days = secondsLeft / DAY;
	if (days > 1)
    {
		secondsLeft -= days * DAY;
		[retVal appendFormat:@"%d days, ", days];
	}
    else if (days == 1)
    {
		secondsLeft -= days * DAY;
		[retVal appendFormat:@"%d day, ", days];
    }
	
	int hours = secondsLeft / HOUR;
	if (hours > 0) {
		secondsLeft -= hours * HOUR;
	}
	
    if (hours > 1)
        [retVal appendFormat:@"%d hours!", hours];
    else if (hours == 1)
        [retVal appendFormat:@"%d hour!", 1];
	else if (hours == 0 && days >= 1) {
		if (days == 1)
			[retVal setString:[NSString stringWithFormat:@"Expires in %d day!", days]];
		else
			[retVal setString:[NSString stringWithFormat:@"Expires in %d days!", days]];
    } else if (days <= 0)
        [retVal setString:@"Expires Soon!"];
	
	return retVal;
}

#pragma mark - "Contants"

// width in portrait, height in landscape
// also defines the width & height of the image
- (CGFloat)shortDimension
{
	if (YRD_IS_4_INCH_RETINA()) {
		return 280.0;
	} else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		return 240.0;
	} else {
		return 560.0;
	}
}

// height in portrait, width in landscape
- (CGFloat)longDimension
{
	CGRect screenBounds = [UIScreen mainScreen].bounds;
	return screenBounds.size.height - 80.0;
}

- (CGFloat)statusBarHeight
{
	CGRect frame = [UIApplication sharedApplication].statusBarFrame;
	// the "height" will always be the shorter dimension (it might be the frame's
	// width or height depending on whether we are in portrait or landscape)
	return MIN(frame.size.width, frame.size.height);
}

// padding/spacing used in various places
- (CGFloat)padding
{
	return 10.0 * [self deviceScaleFactor];
}

- (CGFloat)buttonHeight
{
	return 44.0 * [self deviceScaleFactor];
}

- (CGFloat)buttonWidth
{
	return 80.0 * [self deviceScaleFactor];
}

- (UIColor *)containerBackgroundColor:(YRDMessage *)message
{
	return message.backgroundColor ? message.backgroundColor : [UIColor darkGrayColor];
}

- (UIColor *)textColor:(YRDMessage *)message
{
	return message.textColor ? message.textColor : [UIColor whiteColor];
}

- (UIColor *)expiryTextColor:(YRDMessage *)message
{
	return message.expiryTextColor ? message.expiryTextColor : [UIColor yellowColor];
}

- (UIColor *)confirmButtonColor:(YRDMessage *)message
{
	return message.confirmBackgroundColor ? message.confirmBackgroundColor : [UIColor orangeColor];
}

- (UIColor *)confirmButtonTextColor:(YRDMessage *)message
{
	return message.confirmTextColor ? message.confirmTextColor : [UIColor whiteColor];
}

- (UIColor *)cancelButtonColor:(YRDMessage *)message
{
	return message.cancelBackgroundColor ? message.cancelBackgroundColor : [UIColor grayColor];
}

- (UIColor *)cancelButtonTextColor:(YRDMessage *)message
{
	return message.cancelTextColor ? message.cancelTextColor : [UIColor whiteColor];
}

- (CGFloat)deviceScaleFactor
{
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.0 : 1.0;
}

@end
