
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBTextLayouter.mm
 *
 * Description	: NBTextLayouter
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import <CoreText/CoreText.h>
#import "NBTextLayouter.h"


@interface NBTextLayouter ()

@property (nonatomic, retain) NBTextLayoutFrame          *nbTextFrame;

@end


@implementation NBTextLayouter

- (void)dealloc
{
	[self destoryTextFrame];
	
	[super dealloc];
}

- (instancetype)initWithLayoutFrame:(NBTextLayoutFrame*)nbTextFrame
{
	self = [super init];
	
	if (self)
	{
		_nbTextFrame = [nbTextFrame retain];
	}
	
	return self;
}

- (void)destoryTextFrame
{
	if (_nbTextFrame)
	{
		CFRelease(_nbTextFrame);
		_nbTextFrame = nil;
	}
}

///< 按要求进行逐行排版，标点处理，行尾处理，断行连字符显示
///< 第一步先进行正常排版并可以直接显示
+ (void)textLayouter:(NBTextLayoutFrame*)nbTextFrame
{
	
}

- (BOOL)hasLayouted
{
	return (nil != [_nbTextFrame getFramesetter]);
}

- (BOOL)textFrameLayout
{
	BOOL bRet = NO;
	
	return bRet;
}

///< 创建指定区域内的frame
- (BOOL)createRangeFrameWithRange:(NSRange)strRange rect:(CGRect)rect out:(CTFrameRef &)rangeFrame
{
	return [_nbTextFrame createRangeFrameWithRange:strRange rect:rect out:rangeFrame];
}

@end

