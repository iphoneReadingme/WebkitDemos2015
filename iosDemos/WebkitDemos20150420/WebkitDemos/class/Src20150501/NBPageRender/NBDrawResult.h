/*
 **************************************************************************************
 * Copyright (C) 2005-2011 UC Mobile Limited. All Rights Reserved
 * File			: NBDrawResult.h
 *
 * Description	: 渲染结果类型
 *
 * Author		: daijb@ucweb.com
 * History		:
 *			   Creation, 2014/12/17, daijb, Create the file
 ***************************************************************************************
 **/

#ifndef NovelBox_NBDrawResult_h
#define NovelBox_NBDrawResult_h

typedef enum
{
    NBDrawSuccesful,                  ///< 绘制成功
    NBDrawFailedFrameNotInit,         ///< 绘制失败(绘制框架没初始化)
    NBDrawFailedOverFrame,            ///< 绘制失败(绘制框架越界)
    NBDrawFailedOverPageCount,        ///< 绘制失败(页码超越了当前章节的总页数)
    NBDrawFailedNoBookItem,           ///< 绘制失败(BookItem没创建)
    NBDrawFailedNoConfig,             ///< 绘制失败(LayoutConfig没创建)
    NBDrawFailedNoCatalogue,          ///< 绘制失败(目录还没获取到)
    NBDrawFailedNoChapterItem,        ///< 绘制失败(当前章节信息获取不到)
    NBDrawFailedNoPagingInf,          ///< 绘制失败(没有分页信息)
} NBDrawResult;

#endif
