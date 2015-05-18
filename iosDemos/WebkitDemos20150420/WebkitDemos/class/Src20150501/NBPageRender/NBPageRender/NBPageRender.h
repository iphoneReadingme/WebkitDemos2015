/*
 **************************************************************************************
 * Copyright (C) 2005-2011 UC Mobile Limited. All Rights Reserved
 * File			: NBPageRender.h
 *
 * Description	: 章节分页并渲染
 *
 * Author		: yangcy@ucweb.com
 * History		:
 *			   Creation, 2013/11/26, yangcy, Create the file
 ***************************************************************************************
 **/


#import "NBBookLayoutConfig.h"
#import "NBChapterPagesInfo.h"
#import "NBDrawResult.h"

@interface NBPageRender : NSObject

+ (NBChapterPagesInfo*)splittingPagesForString:(NSString*)content withChapterName:(NSString*)chapterName andLayoutConfig:(NBBookLayoutConfig*)config;

+ (NSString *)normalizedContentText:(NSString *)content;
+ (NSString*)getChapterContentStr:(NSString*)content;


- (instancetype)initWithLayoutConfig:(NBBookLayoutConfig*)config chapterName:(NSString*)chapterName chapterText:(NSString*)chapterText;

/*!
 @function	绘制当前页的文字内容
 
 @param		nTextStartLocation: 当前页文本在整个排版文本字符串中的起始位置
 
 @param		nPageTextLength：当前页面字符长度
 
 */
- (NBDrawResult)drawInContext:(CGContextRef)context withRect:(CGRect)rect withStart:(int)nTextStartLocation withLength:(int)nPageTextLength;

/*格式化绘画样式*/
+ (NSMutableAttributedString*)formatString:(NSString *)contentStr withChapterName:(NSString*)chapterName andLayoutConfig:(NBBookLayoutConfig*)config;

@end


