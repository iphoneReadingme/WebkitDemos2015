/*
 *****************************************************************************
 * Copyright (C) 2005-2011 UC Mobile Limited. All Rights Reserved
 * File			: DemoIncludeHeaders.h
 *
 * Description	: 工程中有多个Demo,每一个都通过包含 一个 *ViewController.h头文件来添加Demo入口.
 *
 * Author		: yangfs@ucweb.com
 * History		: 
 *			   Creation, 2012/8/8, yangfs, Create the file
 ******************************************************************************
 **/


//#define Disenbale_Add_Controller


#import <UIKit/UIKit.h>


///< 3D 透视投影变换矩阵
#import "Demo3DPerspectiveController.h"

///< 文字绘制
#import "DemoGlyphDrawController.h"

///< 2015-04-23 正则表达式 demo"
#import "DemoRegularExpController.h"

///< 2015-03-23 消息通知 demo"
#import "DemoMessageCenterController.h"

///< 2015-03-18 设备摇一摇功能
#import "DemoShakeController.h"

///< 2015-03-11 读写电话号码 demo
#import "DemoIphoneNumberController.h"

///< 2015-01-13 关键帧动画测试
#import "DemoViewCAKeyAnimationController.h"


// 2013-12-16
#import "PageAppViewController.h"
//#import "DemoUIPageViewController.h"


// 2013-11-29
#import "DemoCoreTextDrawController.h"


#ifdef Disenbale_Add_Controller
// 2014-01-07
//#import "DemoUIDeviceVIewController.h"

// 2013-12-16
#import "PageAppViewController.h"
#import "DemoUIPageViewController.h"

// 2013-06-06
#import "DemoViewCALayerController.h"

//#import "WebViewController.h"
//#import "iUCFlashViewController.h"
#import "AnimationViewController.h"
//#import "MapKitViewController.h"

// 百度输入法
//#import "BaiduInputDemoViewController.h"

#endif