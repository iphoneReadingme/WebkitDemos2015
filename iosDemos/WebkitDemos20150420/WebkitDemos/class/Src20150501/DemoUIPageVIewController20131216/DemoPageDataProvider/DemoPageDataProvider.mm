

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

#import "NBPageItem.h"
#import "NBChapterPagesInfo.h"
#import "NBPageRender.h"
#import "DemoPageDataProvider.h"
//#import "DemoTextPageMacroDefine.h"




///< 数据文件路径
//#define kHardcodeNovelDataPath           @"resource/Novel/part.txt"
//#define kHardcodeNovelDataPath           @"resource/Novel/CoreTextTezhanyongbing.txt"
#define kHardcodeNovelDataPath           @"resource/Novel/page2.txt"

///< 私有方法
@interface DemoPageDataProvider (/*DemoViewCoreTextDraw_private*/)
{
	
}

@property (nonatomic, assign) CGRect    frame;
@property (nonatomic, retain) NBBookLayoutConfig    *layoutConfig;
@property (nonatomic, retain) NBChapterPagesInfo    *pagesInfo;
@property (nonatomic, retain) UILabel               *chapterTitle;
@property (nonatomic, copy) NSString                *chapterText;

@end


@implementation DemoPageDataProvider

- (void)dealloc
{
//	[self destoryGlyphRuns];
//	
//	[_text release];
//	_text = nil;
//	
//	CFRelease(_line);
	
	[super dealloc];
}



- (id)initWithRect:(CGRect)rect
{
	if ((self = [super init]))
	{
		_frame = rect;
		[self loadData];
	}
	return self;
}

- (void)loadData
{
	if (_chapterText == nil)
	{
		self.chapterText = [self readPageTextFromFile];
	}
}

- (BOOL)splittingPagesForString
{
	_layoutConfig = [NBBookLayoutConfig bookLayoutConfigWithFontSize:18 andWidth:_frame.size.width andHeight:_frame.size.height];
	[_layoutConfig retain];
	
	///< 分页
	NSString* chapterName = [self getChapterName:0];
	
	self.pagesInfo = [NBPageRender splittingPagesForString:_chapterText
										   withChapterName:chapterName
										   andLayoutConfig:_layoutConfig];
	
	return YES;
}

#pragma mark - == 读取文件数据

- (NSString*)getFilePath
{
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kHardcodeNovelDataPath];
}

- (NSString*)readPageTextFromFile
{
	NSString* pageText = nil;
	
	do
	{
		NSString *filePath = [self getFilePath];
		NSData* fileData = [NSData dataWithContentsOfFile:filePath];
		if ([fileData length] < 1)
		{
			break;
		}
		
		NSString* result = [[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding] autorelease];
		if ([result length] < 1)
		{
			break;
		}
		
		pageText = result;
		
	}while (0);
	
	return pageText;
}

- (NSString*)getPageContentText:(int)pageIndex
{
	NSMutableString* pageContent = nil;
	if (pageIndex < [[_pagesInfo pageItems] count])
	{
		NBPageItem* pageItem = [_pagesInfo getPageItem:pageIndex];
		NSRange range = NSMakeRange([pageItem startInChapter], [pageItem length]);
		NSString* message = [_chapterText substringWithRange:range];
		
		pageContent = [NSMutableString stringWithFormat:@"%@", message];
	}
	
	return pageContent;
}

- (NSString*)getChapterName:(int)pageIndex
{
	///< 分页
	NSString* chapterName = [NSString stringWithFormat:@"【共%d页】当前页面 第【%d】页", [[_pagesInfo pageItems] count], 0];
	
	return chapterName;
}

- (NBBookLayoutConfig*)getLayoutConfig
{
	return _layoutConfig;
}

@end


