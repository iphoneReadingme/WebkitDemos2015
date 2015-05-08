
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

@property(nonatomic, assign) NSInteger numberOfLines;

- (instancetype)initWithFrame:(CGRect)frame with:(NSAttributedString *)attrString range:(NSRange)range;

///< 创建指定区域内的frame
- (BOOL)createRangeFrameWithRange:(NSRange)strRange rect:(CGRect)rect out:(CTFrameRef &)rangeFrame;

- (CTFramesetterRef)getFramesetter;

- (CGRect)intrinsicContentFrame;

- (NSRange)visibleStringRange;

- (NSArray *)stringIndices;

@end

