/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: DemoPageViewDrawText.h
 *
 * Description	: Core Animation基础介绍、简单使用CALayer以及多种动画效果
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on 2013-11-29.
 * History		: modify: 2013-11-29.
 *
 ******************************************************************************
 **/


#import "DemoViewCoreTextDrawMacroDefine.h"
#import "NBBookLayoutConfig.h"


@interface DemoPageViewDrawText : UIView
{
	
}

@property (nonatomic, retain) NBBookLayoutConfig * layoutConfig;

- (void)setPageContentText:(NSString*)text;
- (void)setCurChapterName:(NSString*)chapterName;

@end

