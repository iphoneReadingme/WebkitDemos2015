
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
}

- (instancetype)initWithFrame:(CGRect)frame withAttributedString:(NSAttributedString *)attrString;


- (NSRange)visibleStringRange;


- (NSArray *)getLines;

///< 创建指定区域内的frame
- (BOOL)createFrameInRect:(CGRect)frame withRange:(NSRange)textRange;

- (void)drawLinesWith:(CGContextRef)context inRect:(CGRect)rect;

- (void)updateLinesOriginInRect:(CGRect)frame with:(BOOL)bLastPage;

@end

