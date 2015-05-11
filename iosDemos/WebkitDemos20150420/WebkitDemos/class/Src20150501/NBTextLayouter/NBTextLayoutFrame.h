
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBTextLayoutFrame.h
 *
 * Description	: 提供获取CTFrame参数信息的接口
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import <CoreText/CoreText.h>



@interface NBTextLayoutFrame : NSObject
{
	CGRect _frame;
	NSArray *_lines;
	NSArray *_paragraphRanges;
}

//@property (nonatomic, strong, readonly) NSArray *lines;
@property (nonatomic, assign, readonly) CGRect frame;
@property(nonatomic, assign) NSInteger numberOfLines;

- (instancetype)initWithFrame:(CGRect)frame with:(NSAttributedString *)attrString range:(NSRange)range;

///< 创建指定区域内的frame
- (BOOL)createRangeFrameWithRange:(NSRange)strRange rect:(CGRect)rect ctframe:(CTFrameRef &)rangeFrame;

- (CTFramesetterRef)getFramesetter;

- (NSAttributedString*)getAttibutedString;

- (CGRect)intrinsicContentFrame;

- (NSRange)visibleStringRange;

- (NSArray *)stringIndices;

- (NSArray *)linesVisibleInRect:(CGRect)rect;

- (CGRect)getDefaultFrameShowRect;


- (NSArray *)getLines;
- (BOOL)buildSuggestLines:(NSUInteger)start withRect:(CGRect)frame;

- (void)drawLinesWith:(CGContextRef)context inRect:(CGRect)rect;

@end

