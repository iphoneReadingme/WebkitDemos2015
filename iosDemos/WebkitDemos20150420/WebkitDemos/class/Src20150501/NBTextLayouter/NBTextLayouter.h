
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBTextLayouter.h
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



#import <Foundation/Foundation.h>
#import "NBTextLayoutFrame.h"


@interface NBTextLayouter : NSObject


- (instancetype)initWithLayoutFrame:(NBTextLayoutFrame*)nbTextFrame;

///< 创建指定区域内的frame
- (BOOL)createRangeFrameWithRange:(NSRange)strRange rect:(CGRect)rect out:(CTFrameRef &)rangeFrame;

@end

