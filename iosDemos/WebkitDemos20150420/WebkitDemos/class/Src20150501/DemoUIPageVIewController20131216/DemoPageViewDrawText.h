/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: DemoPageViewDrawText.h
 *
 * Description	: core text 文字排版和绘制绘制
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-05.
 * History		: modify: 2015-05-05.
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

