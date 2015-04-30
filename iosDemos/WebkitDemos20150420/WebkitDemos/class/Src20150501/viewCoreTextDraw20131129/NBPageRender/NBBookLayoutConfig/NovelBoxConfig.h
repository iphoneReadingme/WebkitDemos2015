/*
 *****************************************************************************
 * Copyright (C) 2005-2013 UC Mobile Limited. All Rights Reserved
 * File			: NovelBoxConfig.h
 * Description  : 小说盒子Config
 * Creation		: 9/17/13
 * Author		: daijb@ucweb.com
 * History		: daijb@ucweb.com  9/17/13     Create the file.
 ******************************************************************************
 **/

#ifndef iUCWEB_NovelBoxConfig_h
#define iUCWEB_NovelBoxConfig_h

typedef NS_ENUM(NSInteger, NBPageIndexType)
{
    NBPageIndex_ppre,   ///< 上上一页
    NBPageIndex_pre,    ///< 上一页
    NBPageIndex_cur,    ///< 当前页
    NBPageIndex_next,   ///< 下一页
    NBPageIndex_nnext,  ///< 下下一页
};

///< 默认字体列表
typedef struct
{
    NSInteger fontSize;     ///< 字体大小
    NSInteger rowSpace;     ///< 行距
    NSInteger headIndent;   ///< 首行缩进
}FontConfig;

const FontConfig g_fontAndRowSpace[] =
{
     28 / 2, 12 / 2, 48 / 2
	,30 / 2, 12 / 2, 52 / 2
	,34 / 2, 14 / 2, 64 / 2     ///< 默认配置
    ,40 / 2, 16 / 2, 72 / 2
	,48 / 2, 20 / 2, 92 / 2
	,56 / 2, 22 / 2, 100 / 2
};

#define kCountFontSizeOption     (sizeof(g_fontAndRowSpace) / sizeof(g_fontAndRowSpace[0]))

#define kTitleFontSizeOffset                  4.f
#define kStatuBarHeight                       20.f
#define kDefaultStatusBarHeight               20.f
#define kNaviagtionBarViewHeight              64.f
#define kNavigationHeight                     44.f
#define kNavigationShadowHeight               1.f

#define kBookshelfTitleText                   @"NovelBox/Bookshelf"
#define kBookShelfBackgroupColor              @"NovelBox/BackgroundColor"
#define kCommonCancelText                     @"Common/Cancel"
#define kCommonEditText                       @"Common/Edit"
#define kCommonBackText                       @"Common/Back"
#define kCommonFinishText                     @"Common/Finish"
#define kCommonDeleteText                     @"Common/Delete"
#define kCuttinglineImagePath                 @"NovelBox/TxtReader/Bottom/cutline.png"

#endif
