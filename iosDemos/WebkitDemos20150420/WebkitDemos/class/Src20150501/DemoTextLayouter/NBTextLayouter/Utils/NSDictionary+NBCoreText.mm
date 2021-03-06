//
//  NSDictionary+DTCoreText.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//


#import <CoreText/CoreText.h>

#import "NBCompatibility.h"
#import "NSDictionary+NBCoreText.h"
#import "NBFontDescriptor.h"
#import "NBConstants.h"
#import "NBParagraphStyle.h"

@implementation NSDictionary (NBCoreText)

- (BOOL)isBold
{
	NBFontDescriptor *desc = [self fontDescriptor];
	
	return desc.boldTrait;
}

- (BOOL)isItalic
{
	NBFontDescriptor *desc = [self fontDescriptor];
	
	return desc.italicTrait;
}

- (BOOL)isUnderline
{
	NSNumber *underlineStyle = [self objectForKey:(id)kCTUnderlineStyleAttributeName];
	
	if (underlineStyle)
	{
		return [underlineStyle integerValue] != kCTUnderlineStyleNone;
	}
	
	if (NBModernAttributesPossible())
	{
		underlineStyle = [self objectForKey:NSUnderlineStyleAttributeName];
	
		if (underlineStyle)
		{
			return [underlineStyle integerValue] != NSUnderlineStyleNone;
		}
	}
	
	return NO;
}

- (BOOL)isStrikethrough
{
	NSNumber *strikethroughStyle = [self objectForKey:DTStrikeOutAttribute];
	
	if (strikethroughStyle)
	{
		return [strikethroughStyle boolValue];
	}

	if (NBModernAttributesPossible())
	{
		strikethroughStyle = [self objectForKey:NSStrikethroughStyleAttributeName];
		
		if (strikethroughStyle)
		{
			return [strikethroughStyle boolValue];
		}
	}
	
	return NO;
}

- (NSUInteger)headerLevel
{
	NSNumber *headerLevelNum = [self objectForKey:DTHeaderLevelAttribute];
	
	return [headerLevelNum integerValue];
}

- (BOOL)hasAttachment
{
	id attachment = [self objectForKey:NSAttachmentAttributeName];
	
	if (!attachment)
	{
		// could also be modern NS-style attachment
		attachment = [self objectForKey:@"NSAttachment"];
	}
	
	return attachment!=nil;
}

- (NBParagraphStyle *)paragraphStyle
{
	//if (DTCoreTextModernAttributesPossible())
	{
		NSParagraphStyle *nsParagraphStyle = [self objectForKey:NSParagraphStyleAttributeName];
		
		if (nsParagraphStyle && [nsParagraphStyle isKindOfClass:[NSParagraphStyle class]])
		{
			return [NBParagraphStyle paragraphStyleWithNSParagraphStyle:nsParagraphStyle];
		}
	}
	
	CTParagraphStyleRef ctParagraphStyle = (__bridge CTParagraphStyleRef)[self objectForKey:(id)kCTParagraphStyleAttributeName];
	
	if (ctParagraphStyle)
	{
		return [NBParagraphStyle paragraphStyleWithCTParagraphStyle:ctParagraphStyle];
	}
	
	return nil;
}

#if TARGET_OS_IPHONE
- (CTFontRef)createWithUIFont:(UIFont *)font
{
	return CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
}
#endif

- (NBFontDescriptor *)fontDescriptor
{
	CTFontRef ctFont = (__bridge CTFontRef)[self objectForKey:(id)kCTFontAttributeName];
	
	// on Mac NSFont and CTFont are toll-free bridged, so this works there as well
	
	if (ctFont)
	{
		return [NBFontDescriptor fontDescriptorForCTFont:ctFont];
	}
	
	if (NBModernAttributesPossible())
	{
#if TARGET_OS_IPHONE
		UIFont *uiFont = [self objectForKey:NSFontAttributeName];
		
		if (!uiFont)
		{
			return nil;
		}
		
		// convert font
		ctFont = [self createWithUIFont:uiFont];
		
		if (ctFont)
		{
			NBFontDescriptor *fontDescriptor = [NBFontDescriptor fontDescriptorForCTFont:ctFont];
			
			CFRelease(ctFont);
			
			return fontDescriptor;
		}
#endif
	}
	
	return nil;
}

- (UIColor *)foregroundColor
{
	if (NBModernAttributesPossible())
	{
		UIColor *color = [self objectForKey:NSForegroundColorAttributeName];
		
		if (color)
		{
			return color;
		}
	}
	
	CGColorRef cgColor = (__bridge CGColorRef)[self objectForKey:(id)kCTForegroundColorAttributeName];
	
	if (cgColor)
	{
#if DTCORETEXT_FIX_14684188
		// test if this a valid color, workaround for iOS 7 bug
		size_t componentCount = CGColorGetNumberOfComponents(cgColor);
		
		if (componentCount>0 && componentCount<=4)
		{
			return [DTColor colorWithCGColor:cgColor];
		}
#else
		return [UIColor colorWithCGColor:cgColor];
#endif
	}
	
	// default foreground is black
	return [UIColor blackColor];
}

- (UIColor *)backgroundColor
{
	CGColorRef cgColor = (__bridge CGColorRef)[self objectForKey:DTBackgroundColorAttribute];
	
	if (cgColor)
	{
		return [UIColor colorWithCGColor:cgColor];
	}
	
	if (NBModernAttributesPossible())
	{
		UIColor *color = [self objectForKey:NSBackgroundColorAttributeName];
	
		if (color)
		{
			return color;
		}
	}
	
	// default background is nil
	return nil;
}

- (CGFloat)kerning
{
	if (NBModernAttributesPossible())
	{
		NSNumber *kerningNum = [self objectForKey:NSKernAttributeName];
		
		if (kerningNum)
		{
			return [kerningNum floatValue];
		}
	}
	
	NSNumber *kerningNum = [self objectForKey:(id)kCTKernAttributeName];
	
	return [kerningNum floatValue];
}

- (UIColor *)backgroundStrokeColor
{
	CGColorRef cgColor = (__bridge CGColorRef)[self objectForKey:DTBackgroundStrokeColorAttribute];
	
	if (cgColor)
	{
		return [UIColor colorWithCGColor:cgColor];
	}
	return nil;
}

- (CGFloat)backgroundStrokeWidth
{
	NSNumber *num = [self objectForKey:DTBackgroundStrokeWidthAttribute];
	
	if (num)
	{
		return [num floatValue];
	}

	return 0.0f;
}

- (CGFloat)backgroundCornerRadius
{
	NSNumber *num = [self objectForKey:DTBackgroundCornerRadiusAttribute];
	
	if (num)
	{
		return [num floatValue];
	}
	
	return 0.0f;
}

@end
