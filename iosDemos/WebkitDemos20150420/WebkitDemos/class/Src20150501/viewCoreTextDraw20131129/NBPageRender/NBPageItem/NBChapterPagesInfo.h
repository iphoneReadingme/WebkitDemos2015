/*
 *****************************************************************************
 * Copyright (C) 2005-2013 UC Mobile Limited. All Rights Reserved
 * File			: NBChapterPagesInfo.h
 *
 * Description	: NBChapterPagesInfo (NSCoding)
 *
 * Author		: daijb@ucweb.com
 * History		:
 *			   Creation, 14-6-17, daijb@ucweb.com, Create the file
 ******************************************************************************
 **/

#import <Foundation/Foundation.h>

@class NBPageItem;

@interface NBChapterPagesInfo : NSObject <NSCoding, NSCopying>

@property (retain) NSMutableArray* pageItems;             ///< <NBPageItem *>
@property (nonatomic, assign) BOOL isSplitError;          ///< 该章节分页出现错误
@property (retain) NSString* errorSubstitute;             ///< 分页出错代替文本

- (NBPageItem*)getPageItem:(NSInteger)pageIndex;
- (NSUInteger)getPagesCount;

@end
