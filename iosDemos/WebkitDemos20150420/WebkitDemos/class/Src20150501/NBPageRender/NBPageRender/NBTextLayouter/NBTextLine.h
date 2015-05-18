
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBTextLine.h
 *
 * Description	: 提供获取各个CTLine参数信息的接口
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import "NBParagraphStyle.h"



@interface NBTextLine : NSObject
{
	@package
	
	CTLineRef _line;
	
	CGPoint _baselineOrigin;
	
	CGFloat _ascent;
	CGFloat _descent;
	CGFloat _leading;
	CGFloat _width;
	
	CGFloat _underlineOffset;
	CGFloat _lineHeight;
	
	BOOL _writingDirectionIsRightToLeft;
	BOOL _needsToDetectWritingDirection;
	
	BOOL _hasScannedGlyphRunsForValues;
}


@property (nonatomic, copy) NSString *text;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) CGFloat ascent;
@property (nonatomic, readonly) CGFloat descent;
@property (nonatomic, readonly) CGFloat leading;

@property (nonatomic, readonly) CGFloat trailingWhitespaceWidth;
@property (nonatomic, readonly) CGFloat underlineOffset;
@property (nonatomic, readonly) CGFloat lineHeight;

@property (nonatomic, readonly) NBParagraphStyle *paragraphStyle;

@property (nonatomic, assign) CGPoint baselineOrigin;

@property (nonatomic, assign) BOOL writingDirectionIsRightToLeft;

@property (nonatomic, readonly) NSInteger stringLocationOffset;


- (id)initWithLine:(CTLineRef)line;

- (id)initWithLine:(CTLineRef)line stringLocationOffset:(NSInteger)stringLocationOffset;

- (NSRange)stringRange;

- (BOOL)isHorizontalRule;

- (NSArray *)stringIndices;
- (NSArray *)getGlyphRuns;
- (NSString*)getLineText;

- (void)drawLinesWith:(CGContextRef)context inRect:(CGRect)rect;


@end

