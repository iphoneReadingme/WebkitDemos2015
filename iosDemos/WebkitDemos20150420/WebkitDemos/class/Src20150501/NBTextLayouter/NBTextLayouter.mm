
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
#import "NBTextLine.h"
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

- (void)layoutVisibleString:(NBTextLayoutFrame*)nbTextFrame inRect:(CGRect)rect
{

}

///< 创建指定区域内的frame
- (BOOL)createFrameInRect:(CGRect)frame withRange:(NSRange)textRange
{
	BOOL bRet = NO;
	bRet = [_nbTextFrame createFrameInRect:frame withRange:textRange];
	
	return bRet;
}

- (NSRange)visibleStringRange
{
	return [_nbTextFrame visibleStringRange];
}

- (NSArray *)getLines
{
	return [_nbTextFrame getLines];
}

- (void)drawLinesWith:(CGContextRef)context inRect:(CGRect)rect
{
	[_nbTextFrame drawLinesWith:context inRect:rect];
}

@end

