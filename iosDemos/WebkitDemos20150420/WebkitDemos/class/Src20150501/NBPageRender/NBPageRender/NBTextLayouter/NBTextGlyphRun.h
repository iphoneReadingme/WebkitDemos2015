
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBTextGlyphRun.h
 *
 * Description	: 提供获取各个CTRun参数信息的接口
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import <UIKit/UIKit.h>


@protocol NBTextGlyphRunDelegate <NSObject>

- (NSInteger)stringLocationOffset;
- (BOOL)writingDirectionIsRightToLeft;

- (CGFloat)trailingWhitespaceWidth;

- (NSArray *)glyphRuns;
- (CGPoint)baselineOrigin;

@end


@interface NBTextGlyphRun : NSObject
{
	@package
	
	CGGlyph _bufGlyph[50];
	CGGlyph *_buffer;
	CTRunRef _run;
	CGRect _frame;
	
	CGFloat _offset; // x distance from line origin
	CGFloat _ascent;
	CGFloat _descent;
	CGFloat _leading;
	CGFloat _width;
	
	BOOL _writingDirectionIsRightToLeft;
	BOOL _isTrailingWhitespace;
	
	NSInteger _numberOfGlyphs;
	
	const CGPoint *_glyphPositionPoints;
	
	BOOL _didCalculateMetrics;
	BOOL _didDetermineTrailingWhitespace;
	
	NSRange _stringRange;
}

@property (nonatomic, assign) id<NBTextGlyphRunDelegate> delegate;

@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) NSInteger numberOfGlyphs;
@property (nonatomic, readonly) NSDictionary *attributes;

/**
 The ascent (height above the baseline) of the receiver
 */
@property (nonatomic, readonly) CGFloat ascent;

/**
 The descent (height below the baseline) of the receiver
 */
@property (nonatomic, readonly) CGFloat descent;

/**
 The leading (additional space above the ascent) of the receiver
 */
@property (nonatomic, readonly) CGFloat leading;

/**
 The width of the receiver
 */
@property (nonatomic, readonly) CGFloat width;

/**
 `YES` if the writing direction is Right-to-Left, otherwise `NO`
 */
@property (nonatomic, readonly) BOOL writingDirectionIsRightToLeft;


- (id)initWithRun:(CTRunRef)run offset:(CGFloat)offset withDelegate:(id<NBTextGlyphRunDelegate>)delegate;


- (NSRange)stringRange;

- (BOOL)isTrailingWhitespace;


- (NSArray *)stringIndices;

- (CGRect)frameOfGlyphAtIndex:(NSInteger)index;

- (void)drawRunWith:(CGContextRef)context inRect:(CGRect)rect;

@end

