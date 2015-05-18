/*
 **************************************************************************************
 * Copyright (C) 2005-2011 UC Mobile Limited. All Rights Reserved
 * File			: NBPageRender.mm
 *
 * Description	: 章节分页并渲染
 *
 * Author		: yangcy@ucweb.com
 * History		:
 *			   Creation, 2013/11/26, yangcy, Create the file
 ***************************************************************************************
 **/

#import <CoreText/CoreText.h>
#import "NBPageRender.h"
#import "NBPageItem.h"

#import "NBTextLayouter.h"
#import "NBTextLayoutFrame.h"
#import "NSArray+ExceptionSafe.h"
#import "iUCCommon.h"



#if ! __has_feature(objc_arc)
//[super dealloc];
#define DTCFAttributedStringRef        CFAttributedStringRef
#define DTCFStringRef                  CFStringRef
#define DTid                           id
#else
#define DTCFAttributedStringRef        __bridge CFAttributedStringRef
#define DTCFStringRef                  __bridge CFStringRef
#define DTid                           __bridge id
#endif // #if ! __has_feature(objc_arc)

#define FONTNAME                        @"STHeitiSC-Light"
#define FONTNAMEMedium                  @"STHeitiSC-Medium"

#define SPLIT_ERROR_SUBTITUTE           @"　　本章内容为空。"
#define SPLIT_ERROR_SUBTITUTE_ONLINE    @"　　本章URL为空。"

#define kMaxLineOfFrame     50

///< 上下翻页时，根据排版计算的显示高度来调整上下翻页时机和数据更新时机（UC10.1.0.0这一期暂时不实现）
//#define EnableDynamicGetPageHeight


@interface NBPRFTCoreTextStyle : NSObject
@property (nonatomic, assign)CTTextAlignment textAlignment;
@property (nonatomic, assign)CGFloat fristlineindent;
@property (nonatomic, assign)CGFloat lineSpace;
@property (nonatomic, assign)CGFloat paragraphSpacing;
@property (nonatomic, assign)CGFloat paragraphSpacingBefore;
@end

@implementation NBPRFTCoreTextStyle
@end


@interface NBPageRender ()

@property (nonatomic, retain) NBBookLayoutConfig *layoutConfig;
@property (nonatomic, retain) NSString *chapterTextContent;
@property (nonatomic, retain) NSString *chapterName;

@property (nonatomic, retain) NBTextLayoutFrame  *nblayoutFrame;
@property (nonatomic, retain) NBTextLayouter     *textLayout;
@property (nonatomic, retain) NSAttributedString *attributedString;

@end

@implementation NBPageRender

// 如果全是不可见字符, 则返回false. 如:空格" ", 或者是ASCII控制字符(包括换行回车, 及127 DEL), 对于没有UNICODE中没有编码的暂时不考虑
+ (bool)isVisibleString:(NSString*)checkText
{
	bool bRet = false;
	int i = 0;
	for (; i < [checkText length]; i++)
	{
		unichar ch = [checkText characterAtIndex:i];
		if (' ' < ch && ch != 127)
		{
			bRet = true;
			break;
		}
	}
	
	return bRet;
}

+ (NSString*)getChapterContentStr:(NSString*)content
{
	NSString *contentStr = content;
    
    if ((nil == contentStr) || (0 == [contentStr length]))
    {
        if (iUCCommon::is4inchDisplay())
        {
            contentStr = [NSString stringWithFormat:@"　　\n\n\n\n\n\n\n\n                     本章内容为空"];
        }
        else
        {
            contentStr = [NSString stringWithFormat:@"　　\n\n\n\n\n\n\n               本章内容为空"];
        }
    }
	else
	{
		///< 删除一些空行
		contentStr = [NBPageRender normalizedContentText:content];
	}
	
	return contentStr;
}

+ (NBChapterPagesInfo*)splittingPagesForString:(NSString*)content withChapterName:(NSString*)chapterName andLayoutConfig:(NBBookLayoutConfig*)config
{
    NBChapterPagesInfo * pagesInfo = [[[NBChapterPagesInfo alloc] init] autorelease];
    if (content && ([content length] > 0))
    {
        NSString *contentStr = [NBPageRender getChapterContentStr:content];
        pagesInfo.pageItems = [self _splittingPagesForString:contentStr withChapterName:chapterName andLayoutConfig:config];
    }
    
    if ((nil == pagesInfo.pageItems) || (0 == [pagesInfo.pageItems count]))
    {
        pagesInfo.isSplitError = YES;
        pagesInfo.errorSubstitute = SPLIT_ERROR_SUBTITUTE;
        pagesInfo.pageItems = [self _splittingPagesForString:pagesInfo.errorSubstitute withChapterName:chapterName andLayoutConfig:config];
        assert([pagesInfo.pageItems count]);
    }
    
    return pagesInfo;
}

+ (NSMutableArray*)_splittingPagesForString2:(NSString*)frameShowText withChapterName:(NBTextLayouter*)textLayout andLayoutConfig:(NBBookLayoutConfig*)config
{
	NSMutableArray *pageArray = nil;
	pageArray = [[[NSMutableArray alloc] init] autorelease];
	
	UIEdgeInsets contentInset = config.contentInset;
	
	UIEdgeInsets edgeInsets = contentInset;
	edgeInsets.top = contentInset.bottom;
	edgeInsets.bottom = contentInset.top;
	
	NSInteger textRangeStart = 0;
	BOOL bBreak = NO;
	for(size_t i = 0; i < INT16_MAX; i++)
	{
		// 由于在绘制文字时, 坐标系会沿X轴发生翻转, 故Y方向需要调换
		
		CGRect columnFrame = CGRectMake(i*config.pageWidth, 0, config.pageWidth, config.pageHeight);
		columnFrame = UIEdgeInsetsInsetRect(columnFrame, edgeInsets);
		NSRange textRange = NSMakeRange(textRangeStart, 0);
		
		BOOL bRet = [textLayout createFrameInRect:columnFrame withRange:textRange];
		if (!bRet)
		{
			break;
		}
		
		NSRange visibleRange = [textLayout visibleStringRange];
		NBPageItem *item = [[[NBPageItem alloc] init] autorelease];
		item.startInChapter = textRangeStart;
		item.length = visibleRange.length;
		item.pageIndex = i;
		
		[pageArray addObject:item];
		textRangeStart += visibleRange.length;
		
		if(textRangeStart >= [frameShowText length]) ///< 删除最后一个全空页
		{
			NSString* strEnd = [frameShowText substringFromIndex:visibleRange.location];
			strEnd = [strEnd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			//DDLogVerbose(@"最后一页面[%d]", (int)i);
			if ((0 == [strEnd length]) || ![NBPageRender isVisibleString:strEnd])
			{
				// 显示空白,则删除
				[pageArray removeObject:item];
			}
			
			bBreak = YES;
		}
		
		if (bBreak)
		{
			break;
		}
	}
	
	return pageArray;
}

// 返回 NBPageItem array
+ (NSMutableArray*)_splittingPagesForString:(NSString*)content withChapterName:(NSString*)chapterName andLayoutConfig:(NBBookLayoutConfig*)config
{
    NSMutableArray *pageArray = nil;
	if ([content length] > 0)
	{
		//HTIME_DUMP_IF("splittingPagesForString", 50);
		
		NSString* frameShowText = [NBPageRender getShowTextOfChapter:content withChapterName:chapterName andLayoutConfig:config];
		
		NSMutableAttributedString* attr = [NBPageRender formatString:content withChapterName:chapterName andLayoutConfig:config];
		NBTextLayoutFrame *layoutFrame = [[NBTextLayoutFrame alloc] initWithFrame:CGRectZero withAttributedString:attr];
		
		NBTextLayouter* textLayout = [[NBTextLayouter alloc] initWithLayoutFrame:layoutFrame];
		
		NSInteger nRunCount = 1;
		
		NSDate* startDate = [NSDate date];
		
//		int i = 1;
//		for (; i < 100; i++)
//		{
//			NBTextLayoutFrame *layoutFrame = [[NBTextLayoutFrame alloc] initWithFrame:CGRectZero withAttributedString:attr];
//			
//			NBTextLayouter* textLayout = [[NBTextLayouter alloc] initWithLayoutFrame:layoutFrame];
//			
//			
//			pageArray = [NBPageRender _splittingPagesForString2:frameShowText withChapterName:textLayout andLayoutConfig:config];
//			
//			[layoutFrame release];
//			[textLayout release];
//		}
//		nRunCount += i;
		
		
		pageArray = [NBPageRender _splittingPagesForString2:frameShowText withChapterName:textLayout andLayoutConfig:config];
		
		NSDate* endDate = [NSDate date];
		CGFloat time = [endDate timeIntervalSinceReferenceDate] - [startDate timeIntervalSinceReferenceDate];
		time /= nRunCount;
		NSInteger nLength = [frameShowText length] > 10 ? 10 : [frameShowText length];
		
		NSMutableString* strTemp = [NSMutableString stringWithCapacity:0];
		NSString* message = [NSString stringWithFormat:@"【本章节文字长度：%ld】:%@", (long)[frameShowText length], [frameShowText substringToIndex:nLength]];
		[strTemp appendFormat:@"%@", message];
		NSLog(@"\n%@", message);
		//message = [NSString stringWithFormat:@"本章节排版时间：【页数：%d】，【%f】", (int)[pageArray count], [endDate timeIntervalSinceReferenceDate] - [startDate timeIntervalSinceReferenceDate]];
		message = [NSString stringWithFormat:@"本章节排版时间：【页数：%d】，【%f】, 【单页：%f】", (int)[pageArray count], time, time/[pageArray count]];
		[strTemp appendFormat:@"%@", message];
		NSLog(@"\n%@", message);
		
		[layoutFrame release];
		[textLayout release];
	}
	
    return pageArray;
}

#ifdef EnableDynamicGetPageHeight
///< 计算页面排版显示占用的区域高度
+ (CGFloat)getLastPageFrameHeight:(CTFrameRef)pageFrame withRect:(CGRect)columnFrame andLayoutConfig:(NBBookLayoutConfig*)config
{
	CGFloat fHeight = 0;
	
	//计算这一栏，有几行文字。
	NSArray *lines = (NSArray*)CTFrameGetLines(pageFrame);
	
	int nLineCount = [lines count];
	CGPoint lineOrigins[nLineCount];
	
	if (nLineCount > 0)
	{
		CTFrameGetLineOrigins(pageFrame, CFRangeMake(0, 0), lineOrigins);
		
		CGFloat y = lineOrigins[nLineCount - 1].y - 3.0;
		y -= config.lineSpace;
		if (y < 0)
		{
			y = 0;
		}
		
		fHeight = columnFrame.size.height - y;
		
		CGFloat fLineHeight = 0;
		if (nLineCount >= 2)
		{
			fLineHeight = (lineOrigins[0].y - lineOrigins[1].y);
			
			CGFloat y = lineOrigins[nLineCount-1].y - 2.5;
			if (y < fLineHeight)
			{
				fHeight = columnFrame.size.height;
			}
		}
	}
	
	return fHeight;
}
#endif

///< 返回当前章节显示的文本内容（上下翻页时第一页面带章节标题名）
+ (NSString*)getShowTextOfChapter:(NSString *)contentStr withChapterName:(NSString*)chapterName andLayoutConfig:(NBBookLayoutConfig*)config
{
	BOOL bShowTitle = (config.showBigTitle && [chapterName length] > 0);   ///< 文字排版时是否显示标题
	
	NSString* chapterText = contentStr;
	if (bShowTitle)
	{
		chapterText = [NSString stringWithFormat:@"\n\n%@\n\n\n%@", chapterName, contentStr];
	}
	
	return chapterText;
}

/*格式化绘画样式*/
+ (NSMutableAttributedString*)formatString:(NSString *)contentStr withChapterName:(NSString*)chapterName andLayoutConfig:(NBBookLayoutConfig*)config
{
	if (config == nil || ([contentStr length] < 1))
	{
		return nil;
	}
	
	BOOL bShowTitle = (config.showBigTitle && [chapterName length] > 0);   ///< 文字排版时是否显示标题
	NSInteger nStart = 0;
	NSInteger nTextLength = [contentStr length];  ///< 章节内容文字长度（不含标题文字）
	
	NSString* frameShowText = [NBPageRender getShowTextOfChapter:contentStr withChapterName:chapterName andLayoutConfig:config];
    NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:frameShowText] autorelease];
	
	///< 格式化章节内容
	if (bShowTitle)
	{
		///< 补充5个换行符
		nStart = [chapterName length] + 5;
		
		///< 格式化标题
		NSRange range = NSMakeRange(0, nStart);
		[NBPageRender formatChapterTitle:attributedString with:range andLayoutConfig:config];
	}
	NSRange range = NSMakeRange(nStart, nTextLength);
	[NBPageRender formatChapterContent:attributedString with:range andLayoutConfig:config];
	
	return attributedString;
}

+ (void)formatChapterTitle:(NSMutableAttributedString*)attributedString with:(NSRange)range andLayoutConfig:(NBBookLayoutConfig*)config
{
	if (range.length < 1)
	{
		return;
	}
	
	///< 1. 标题颜色
	UIColor* colorText = [UIColor blueColor];
	if (config != nil && config.pageTextColor != nil)
	{
		colorText = config.pageTextColor;
	}
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)colorText.CGColor range:range];
	
    ///< 2. 设置标题字体
	CGFloat fontSize = config.titleFontSize;
	NSString* fontName = FONTNAMEMedium;  ///< 标题加粗
	UIFont* fontObj = [NBPageRender loadCustomBoldFont:fontName with:fontSize];
	
	if ([[fontObj fontName] length] > 0)
	{
		CTFontRef font = CTFontCreateWithName((DTCFStringRef)fontObj.fontName, fontSize, NULL);
		if (font != nil)
		{
			[attributedString addAttribute:(NSString *)kCTFontAttributeName value:(DTid)font range:range];
			CFRelease(font);
		}
    }
    
	NBPRFTCoreTextStyle *stype = [[[NBPRFTCoreTextStyle alloc] init] autorelease];
	if (stype != nil)
	{
		stype.textAlignment = kCTLeftTextAlignment;
		stype.fristlineindent = 0.0f;
		stype.lineSpace = 0;
		stype.paragraphSpacing = 0;
		stype.paragraphSpacingBefore = 0;
		
		//设置对齐方式、行间距、首行缩进
		[NBPageRender formatTextAttributes:attributedString with:range withStyle:stype];
	}
}

+ (void)formatChapterContent:(NSMutableAttributedString*)attributedString with:(NSRange &)range andLayoutConfig:(NBBookLayoutConfig*)config
{
	///< 1. 文本内容颜色
	UIColor* colorText = [UIColor blueColor];
	if (config != nil && config.pageTextColor != nil)
	{
		colorText = config.pageTextColor;
	}
    [attributedString addAttribute:(id)kCTForegroundColorAttributeName value:(id)colorText.CGColor range:range];
	
    ///< 2. 设置文本内容字体
	CGFloat fontSize = config.fontSize;
	UIFont* fontObj = [NBPageRender loadCustomFont:[config fontName] with:fontSize];
	
	if ([[fontObj fontName] length] > 0)
	{
		CTFontRef font = CTFontCreateWithName((DTCFStringRef)fontObj.fontName, fontSize, NULL);
		if (font != nil)
		{
			[attributedString addAttribute:(NSString *)kCTFontAttributeName value:(DTid)font range:range];
			CFRelease(font);
		}
	}
	
	NBPRFTCoreTextStyle *stype = [[[NBPRFTCoreTextStyle alloc] init] autorelease];
	if (stype != nil)
	{
		stype.textAlignment = kCTLeftTextAlignment;
		stype.fristlineindent = config.firstLineHeadIndent;
		stype.lineSpace = config.lineSpace;
		stype.paragraphSpacing = config.paragraphSpacing;
		stype.paragraphSpacingBefore = config.paragraphSpacingBefore;
		
		//设置对齐方式、行间距、首行缩进
		[NBPageRender formatTextAttributes:attributedString with:range withStyle:stype];
	}
}

//#define Enable_Custom_font

+ (UIFont*)loadCustomBoldFont:(NSString*)fontName with:(int)fontSize
{
	UIFont* fontObj = nil;
	
	if (fontObj == nil)
	{
#ifdef Enable_Custom_font
		fontObj = [NBPageRender loadCustomFont:fontSize];
#else
		fontObj = [UIFont fontWithName:fontName size:fontSize];
#endif
		if (fontObj == nil)
		{
			fontName = FONTNAMEMedium;
			fontObj = [UIFont fontWithName:fontName size:fontSize];
		}
		if (fontObj == nil)
		{
			fontObj = [UIFont boldSystemFontOfSize:fontSize];  ///< 系统字体;
		}
	}
	
	return fontObj;
}

+ (UIFont*)loadCustomFont:(NSString*)fontName with:(int)fontSize
{
	UIFont* fontObj = nil;
	
	if (fontObj == nil)
	{
#ifdef Enable_Custom_font
		fontObj = [NBPageRender loadCustomFont:fontSize];
#else
		fontObj = [UIFont fontWithName:fontName size:fontSize];
#endif
		if (fontObj == nil)
		{
			fontName = FONTNAME;
			fontObj = [UIFont fontWithName:fontName size:fontSize];
		}
		if (fontObj == nil)
		{
			fontObj = [UIFont systemFontOfSize:fontSize];  ///< 系统字体;
		}
	}
	
	return fontObj;
}

#ifdef Enable_Custom_font
+ (UIFont*)loadCustomFont:(int)fontSize
{
	static UIFont* fontObj = nil;
	if (fontObj == nil)
	{
		fontObj = [NBPageRender dynamicLoadFont:fontSize];
		if (fontObj == nil)
		{
			fontObj = [UIFont systemFontOfSize:fontSize];  ///< 系统字体;
		}
	}
	
	return fontObj;
}

+ (NSString*)getFontFilePath
{
	NSString* filePath = [NSString stringWithFormat:@"%@/Documents/huawenxingkai.ttf", NSHomeDirectory()];
	
	BOOL bExist = NO;
	bExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	if (bExist != YES)
	{
		filePath = [NSString stringWithFormat:@"%@/Library/Application Support/others/huawenxingkai.ttf", NSHomeDirectory()];
		bExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	}
	
	if (bExist != YES)
	{
		filePath = nil;
	}
	
	return filePath;
}

+ (UIFont*)dynamicLoadFont:(int)fontSize
{
	UIFont* fontObj = nil;
	
	//加载字体
	CFErrorRef error;
	NSString *fontPath = [NBPageRender getFontFilePath]; // a TTF file in iPhone Documents folder //字体文件所在路径
	if ([fontPath length] < 1)
	{
		return fontObj;
	}
	
	CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([fontPath UTF8String]);
	CGFontRef customFont = CGFontCreateWithDataProvider(fontDataProvider);
	
	bool bRegister = CTFontManagerRegisterGraphicsFont(customFont, &error);
	///＜ 使用完之后，还要卸载
	
	if (!bRegister)
	{
		//如果注册失败，则不使用
		CFStringRef errorDescription = CFErrorCopyDescription(error);
		NSLog(@"Failed to load font: %@", errorDescription);
		CFRelease(errorDescription);
	}
	else
	{
		//字体名
		NSString *fontName = (__bridge NSString *)CGFontCopyFullName(customFont);
		NSLog(@"fontName=%@", fontName);
		fontObj = [UIFont fontWithName:fontName size:fontSize];
	}
	
	CFRelease(customFont);
	CGDataProviderRelease(fontDataProvider);
	
	return fontObj;
}
#endif // #ifdef Enable_Custom_font

+ (void)formatTextAttributes:(NSMutableAttributedString*)attributedString with:(NSRange&)range withStyle:(NBPRFTCoreTextStyle*)textStyle
{
	///< 2. 换行模式
	CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;                 // (以字符为单位)当一行中最后一个位置的大小不能容纳一个字符时，才进行换行。
	
    CTParagraphStyleSetting lineBreakModeSet;
    lineBreakModeSet.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakModeSet.value = &lineBreak;
    lineBreakModeSet.valueSize = sizeof(lineBreak);
	
    ///< 3. 创建文本对齐方式
    CTTextAlignment textAlignment = kCTJustifiedTextAlignment;//这种对齐方式会自动调整，使左右始终对齐
	textAlignment = textStyle.textAlignment;
    CTParagraphStyleSetting alignmentSet;
    alignmentSet.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
    alignmentSet.value=&textAlignment;
    alignmentSet.valueSize=sizeof(textAlignment);
	
    /// 4. 首行缩进
    CGFloat fristlineindent = textStyle.fristlineindent;
    CTParagraphStyleSetting fristlineSet;
    fristlineSet.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
    fristlineSet.value = &fristlineindent;
    fristlineSet.valueSize = sizeof(fristlineindent);
    
	///< 5. 设置文本行间距
    CGFloat lineSpace = textStyle.lineSpace;
    CTParagraphStyleSetting lineSpacingSet;
    lineSpacingSet.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    lineSpacingSet.value = &lineSpace;
    lineSpacingSet.valueSize = sizeof(lineSpace);
	
	///< 6. 设置文本段间距
    CGFloat paragraphSpacing = textStyle.paragraphSpacing;
    CTParagraphStyleSetting paragraphSpacingSet;
    paragraphSpacingSet.spec = kCTParagraphStyleSpecifierParagraphSpacing;
    paragraphSpacingSet.value = &paragraphSpacing;
    paragraphSpacingSet.valueSize = sizeof(paragraphSpacing);
	
	///< 7. 设置段前间距
    CGFloat paragraphSpacingBefore = textStyle.paragraphSpacingBefore;
    CTParagraphStyleSetting paragraphSpacingBeforeSet;
    paragraphSpacingBeforeSet.spec = kCTParagraphStyleSpecifierParagraphSpacingBefore;
    paragraphSpacingBeforeSet.value = &paragraphSpacingBefore;
    paragraphSpacingBeforeSet.valueSize = sizeof(paragraphSpacingBefore);
	
    //组合设置
    CTParagraphStyleSetting settings[] =
	{
		alignmentSet,
		fristlineSet,
		lineSpacingSet,
		paragraphSpacingSet,
		paragraphSpacingBeforeSet,
		lineBreakModeSet,
    };
	
	//通过设置项产生段落样式对象
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
	if (style)
	{
		// build attributes
		NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(id)style forKey:(id)kCTParagraphStyleAttributeName ];
		
		// set attributes to attributed string
		[attributedString addAttributes:attributes range:range];
		
		CFRelease(style);
	}
}

/*格式化章节内容*/
+ (NSString *)normalizedContentText:(NSString *)content
{
//	HTIME_DUMP_IF("[normalizedContentText]", 0);
    //替换分段符
    NSString *contentStr = [[[content stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"] stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"] stringByReplacingOccurrencesOfString:@"[br]" withString:@"\n"];
    contentStr = [[contentStr stringByReplacingOccurrencesOfString:@"<p>" withString:@""] stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    
    NSArray* array = [contentStr componentsSeparatedByString:@"\n"];
    NSMutableArray *newArray = [[[NSMutableArray alloc] initWithArray:array] autorelease];
    
    for (NSInteger i = newArray.count-1; i >= 0; i--) {
        NSString *paraStr = [newArray safe_ObjectAtIndex:i];
        paraStr = [paraStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([paraStr isEqualToString:@""]) {
            [newArray removeObjectAtIndex:i];
        } else {
            if (i != 0 && !([paraStr hasPrefix:@"----------"] || [paraStr hasPrefix:@"************"]))
			{
                paraStr = [NSString stringWithFormat:@"　　%@", paraStr];
            }
            [newArray replaceObjectAtIndex:i withObject:paraStr];
        }
    }
    
    NSString *newContentStr = [newArray componentsJoinedByString:@"\n"];
    
    return newContentStr;
}

- (instancetype)initWithLayoutConfig:(NBBookLayoutConfig*)config chapterName:(NSString*)chapterName chapterText:(NSString*)chapterText
{
    assert(config);
    self = [super init];
    if (self)
    {
        self.layoutConfig = config;
		self.chapterName = chapterName;
        
		NSString * contentStr = nil;
		if (chapterText && [chapterText length])
		{
			contentStr = [NBPageRender getChapterContentStr:chapterText];
		}
		
        if (contentStr)
        {
            self.chapterTextContent = contentStr;
			
			UIEdgeInsets contentInset = config.contentInset;
			
			// 由于在绘制文字时, 坐标系会沿X轴发生翻转, 故Y方向需要调换
			UIEdgeInsets edgeInsets = contentInset;
			edgeInsets.top = contentInset.bottom;
			edgeInsets.bottom = contentInset.top;
			
			CGRect columnFrame = CGRectMake(0, 0, config.pageWidth, config.pageHeight);
			columnFrame = UIEdgeInsetsInsetRect(columnFrame, edgeInsets);
			
			NSMutableAttributedString* attr = [NBPageRender formatString:contentStr withChapterName:chapterName andLayoutConfig:config];
			
			_nblayoutFrame = [[NBTextLayoutFrame alloc] initWithFrame:columnFrame withAttributedString:attr];
			
			_textLayout = [[NBTextLayouter alloc] initWithLayoutFrame:_nblayoutFrame];
			
			BOOL bRet = [_textLayout createFrameInRect:columnFrame withRange:NSMakeRange(0, 0)];
			if (!bRet)
			{
				[self destoryTextLayout];
				[self destoryFrame];
			}
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.layoutConfig = nil;
	self.chapterName = nil;
    self.chapterTextContent = nil;
	[self destoryTextLayout];
	[self destoryFrame];
	[self destoryFrame];
	
    [super dealloc];
}

- (void)destoryTextLayout
{
	[_textLayout release];
	_textLayout = nil;
}

- (void)destoryFrame
{
	[_nblayoutFrame release];
	_nblayoutFrame = nil;
}

- (NBDrawResult)drawInContext:(CGContextRef)context withRect:(CGRect)rect withStart:(int)nTextStartLocation withLength:(int)nPageTextLength
{
    //HTIME_DUMP_IF("NBPageRender:drawInContext", 20);
	
	NBBookLayoutConfig* frameConfig = self.layoutConfig;
	NSString* frameShowText = [NBPageRender getShowTextOfChapter:self.chapterTextContent withChapterName:self.chapterName andLayoutConfig:frameConfig];
    if (nTextStartLocation >= [frameShowText length])
    {
        //DDLogError(@"!!!drawInContext，绘制文本超界。");
        return NBDrawFailedOverFrame;
    }
	
	BOOL bLastPage = NO;
	if (nTextStartLocation + nPageTextLength >= [frameShowText length])
	{
		nPageTextLength = (int)([frameShowText length] - nTextStartLocation);
		bLastPage = YES;
	}
	
	UIEdgeInsets contentInset = frameConfig.contentInset;
	// 由于在绘制文字时, 坐标系会沿X轴发生翻转, 故Y方向需要调换
	UIEdgeInsets edgeInsets = contentInset;
	edgeInsets.top = contentInset.bottom;
	edgeInsets.bottom = contentInset.top;
	
	CGRect columnFrame = rect;
	columnFrame.size = CGSizeMake(frameConfig.pageWidth, frameConfig.pageHeight);
	columnFrame = UIEdgeInsetsInsetRect(columnFrame, edgeInsets);
	//assert(rect.size.height == frameConfig.pageHeight);
	//DDLogVerbose(@"==columnFrame=(%@)", NSStringFromCGRect(columnFrame));
	
	NSDate* startDate = [NSDate date];
	
	NSRange textRange = NSMakeRange(nTextStartLocation, nPageTextLength);
	BOOL bRet = [_textLayout createFrameInRect:columnFrame withRange:textRange];
	if (!bRet)
	{
		[self destoryFrame];
	}
	
	NSDate* endDate = [NSDate date];
	
	NSInteger nLength = ([frameShowText length] > textRange.location + 10) ? 10 : [frameShowText length] - textRange.location;
	
	NSRange testRange = NSMakeRange(textRange.location, nLength);
	NSMutableString* strTemp = [NSMutableString stringWithCapacity:0];
	NSString* message = [NSString stringWithFormat:@"【当前页面文字长度：%ld】:%@", (long)textRange.length, [frameShowText substringWithRange:testRange]];
	[strTemp appendFormat:@"%@", message];
	NSLog(@"%@", message);
	message = [NSString stringWithFormat:@"当前页面排版时间：【%f】", [endDate timeIntervalSinceReferenceDate] - [startDate timeIntervalSinceReferenceDate]];
	[strTemp appendFormat:@"%@", message];
	NSLog(@"%@", message);
	
//	[NBPageRender showToast:strTemp with:NBFeedbackTypeText];
	
	//翻转坐标系统（文本原来是倒的要翻转下）
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	[_textLayout drawLinesWith:context inRect:columnFrame];
	
    return NBDrawSuccesful;
}

@end

