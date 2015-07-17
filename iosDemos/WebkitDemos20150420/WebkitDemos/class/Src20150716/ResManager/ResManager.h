
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: ResManager.h
 *
 * Description	: 资源加载接口
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-07-16.
 * History		: modify: 2015-07-16.
 *
 ******************************************************************************
 **/


#import <UIKit/UIKit.h>


#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif

	
#pragma mark 获取图片等资源
	
	UIImage* resGetImage(NSString* shotName);                   ///<从主题资源获取图片文件（支持2x，3x图片）

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif
