
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: DemoPageDataProvider.h
 *
 * Description	: DemoPageDataProvider
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import <Foundation/Foundation.h>
#import "NBBookLayoutConfig.h"


@interface DemoPageDataProvider : NSObject
{
}
- (id)initWithRect:(CGRect)rect;
- (BOOL)splittingPagesForString;

- (NSString*)getPageContentText:(int)pageIndex;

- (NSString*)getChapterName:(int)pageIndex;

- (NBBookLayoutConfig*)getLayoutConfig;

@end

