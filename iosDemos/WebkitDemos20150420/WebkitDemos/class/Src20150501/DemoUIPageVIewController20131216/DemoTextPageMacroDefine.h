/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: DemoTextPageMacroDefine.h
 *
 * Description	: Core Animation基础介绍、简单使用CALayer以及多种动画效果
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-05.
 * History		: modify: 2015-05-05.
 *
 ******************************************************************************
 **/



//#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>


#define kPageStartIndex                 1

#define kStatusBarHeight                20
#define kNavigationBarHeight            44

///< 数据文件路径
//#define kHardcodeNovelDataPath           @"resource/Novel/part.txt"
#define kHardcodeNovelDataPath           @"resource/Novel/CoreTextTezhanyongbing.txt"



// =======================测试日志宏定义=======================
// 上传代码时关闭测试宏  CALayer macro define


// for test, should comment before committed
//#define CALMD_LOG_DEBUG_ENABLE
//
//#ifdef CALMD_LOG_DEBUG_ENABLE
//
//#define CALMD_LOG_NSLOG(...)                       NSLog(__VA_ARGS__)
//#else
//#define CALMD_LOG_NSLOG(...)                       do{}while(0)
//#endif
// =======================测试日志宏定义=======================
