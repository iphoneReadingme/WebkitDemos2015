
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "DemoPageViewDrawText.h"
#import "DemoViewCoreTextDrawMacroDefine.h"
#import "PageSplitRender.h"


#define			FONTNAME			@"STHeitiSC-Light"

///< 私有方法
@interface DemoPageViewDrawText ()


@property (nonatomic, copy) NSString * pageText;

- (void)addSomeViews:(CGRect)frame;
- (void)forTest;
- (void)releaseObject;

@end


// =================================================================
#pragma mark-
#pragma mark UIAppFSIconView实现

@implementation DemoPageViewDrawText


- (void)forTest
{
	// for test
//	self.backgroundColor = [UIColor brownColor];
	self.layer.borderWidth = 4;
	self.layer.borderColor = [UIColor colorWithRed:0.0 green:0 blue:1.0 alpha:1.0].CGColor;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code.
		[self forTest];
		self.backgroundColor = [UIColor grayColor];
		[self addSomeViews:[self bounds]];
		
    }
    return self;
}

- (void)dealloc
{
	[self releaseObject];
    
    [super dealloc];
}

-(void)releaseObject
{
	self.layoutConfig = nil;
}

// =================================================================
#pragma mark- == 边框圆角半径 设置层的背景颜色，层的设置圆角半径为20

- (BOOL)isPortraitScreen    ///< 是否竖屏
{
	UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
	return UIInterfaceOrientationIsPortrait(statusBarOrientation);
	
	//CGRect bounds = [UIGlobal getMainBounds];
	//return (bounds.size.height > bounds.size.width);
}

// =================================================================

- (void)addSomeViews:(CGRect)frame
{
//	[self addButtons];
}


// =================================================================
#pragma mark-


- (void)setText:(NSString*)text
{
	self.pageText = text;
}



// =================================================================
#pragma mark- == Core Animation之多种动画效果
// 1、把图片移到右下角变小透明
// =================================================================
#pragma mark-
#pragma mark 创建按钮

- (UIButton*)createButton:(int)nTag withName:(NSString*)pStrName withTitle:(NSString*)pTitle
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[button addTarget:self action:@selector(onButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
	button.tag = nTag;
	button.accessibilityLabel = pStrName;
	[button setTitle:pTitle forState:UIControlStateNormal];
	
	button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
	
//	[self addSubview:button];
	//[button retain];
	
	return button;
}

- (void)addButtons
{
	CGRect frame = [self bounds];
	CGRect btnRect = CGRectMake(0, 0, 100, 64);
	btnRect.origin.x = frame.size.width - btnRect.size.width;
	int nIndex = 0;
	UIButton* pBtn = nil;
	
	// "把图片移到右下角变小透明"按钮
	pBtn = [self createButton:nIndex withName:@"UIButtonTest1" withTitle:@"返回"];
	[pBtn setFrame:btnRect];
	[self addSubview:pBtn];
}

- (void)onButtonClickEvent:(UIButton*)sender
{
//	if ([[self superview] respondsToSelector:@selector(onButtonBack)])
//	{
//		[[self superview] performSelector:@selector(onButtonBack)];
//	}
}

#define kChapterNameText  @"第一章节　章节标题名"
- (void)drawRect:(CGRect)rect
{
	if ([_pageText length] < 1)
	{
		return;
	}
    
	int nFontSize = _layoutConfig.fontSize;
	
	// Initialize a graphics context in iOS.
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self drawInContext:context withRect:rect font:nFontSize withText:_pageText];
}

- (CGFloat)getLineSpace
{
	CGFloat lineSpace = 4.0f;
	
	return lineSpace;
}

///< 返回当前章节显示的文本内容（上下翻页时第一页面带章节标题名）
- (NSString*)getShowTextOfChapter:(NSString *)contentStr withChapterItem:(NSString*)chapterName andLayoutConfig:(NBBookLayoutConfig*)config
{
	BOOL bShowTitle = (config.showBigTitle && [chapterName length] > 0);   ///< 文字排版时是否显示标题
	
	NSString* chapterText = contentStr;
	if (bShowTitle)
	{
		chapterText = [NSString stringWithFormat:@"%@\n\n%@", chapterName, contentStr];
	}
	
	return chapterText;
}

/*格式化绘画样式*/
- (CTFramesetterRef)formatString:(NSString *)contentStr size:(CGFloat)fontSize chapName:(NSString*)chapterName andLayoutConfig:(NBBookLayoutConfig*)config
{
	if (config == nil || ([contentStr length] < 1))
	{
		return nil;
	}
	CTFramesetterRef framesetter = nil;
	framesetter = [PageSplitRender formatString:contentStr withChapterName:chapterName andLayoutConfig:self.layoutConfig];
	
	return 	framesetter;
}

- (void)drawInContext:(CGContextRef)context withRect:(CGRect)rect font:(int)fontSize withText:(NSString*)pageContent
{
	if ([pageContent length] < 1)
	{
		return;
	}
    //assert(CGSizeEqualToSize(rect.size, CGSizeMake(self.layoutConfig.pageWidth, self.layoutConfig.pageHeight)));
	
	//CGAffineTransform originTF = CGContextGetCTM(context); // for test 变换矩阵
	//originTF = CGAffineTransformIdentity;
	//翻转坐标系统（文本原来是倒的要翻转下）
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
    //originTF = CGContextGetCTM(context); // for test 变换矩阵
	// In this simple example, initialize a rectangular path.
	//CGRect bounds = CGRectMake(0, 0, rect.size.width, rect.size.height);
	//CGPathAddRect(path, &CGAffineTransformIdentity, bounds );
	
	// 由于在绘制文字时, 坐标系会沿X轴发生翻转, 故Y方向需要调换
	UIEdgeInsets edgeInsets = self.layoutConfig.contentInset;
	edgeInsets.top = self.layoutConfig.contentInset.bottom;
	edgeInsets.bottom = self.layoutConfig.contentInset.top;
	
    CGRect columnFrame = rect;
//    columnFrame.size = CGSizeMake(self.layoutConfig.pageWidth, self.layoutConfig.pageHeight);
    columnFrame.size = CGSizeMake(rect.size.width, rect.size.height);
    columnFrame = UIEdgeInsetsInsetRect(columnFrame, edgeInsets);
	
	// In this simple example, initialize a rectangular path.
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, &CGAffineTransformIdentity, columnFrame);
	
    CTFramesetterRef framesetter = nil;
	framesetter = [self formatString:pageContent size:fontSize chapName:kChapterNameText andLayoutConfig:_layoutConfig];
	
    CTFrameRef contentFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), framePath, NULL);
	
	if (contentFrame)
	{
		CTFrameDraw(contentFrame, context);
	}
	
	if (contentFrame)
	{
		CFRelease(contentFrame);
	}
	
	if (framesetter)
	{
		CFRelease(framesetter);
	}
	
	if (framePath)
	{
		CFRelease(framePath);
	}
}

//CTFrameRef contentFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), framePath, NULL);

- (void)drawRect:(CGContextRef)context withRect:(CGRect)rect
{
	//翻转坐标系统（文本原来是倒的要翻转下）
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	NSString* contentStr =  @"其实流程是这样的： 1、生成要绘制的NSAttributedString对象。…";
	
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:contentStr] autorelease];
	
	//设置对齐方式、行间距、首行缩进
	CTTextAlignment textAlignment = kCTLeftTextAlignment;
	CGFloat lineSpace = 4.0f;
	CGFloat paragraphSpacing = 10.0f;
	CGFloat headIndent = 0.0f;
	//创建设置数组
	CTParagraphStyleSetting settings[] = {
		// 设置文本对齐方式
		{ kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment },
		// 设置文本行间距
		{ kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(lineSpace), &lineSpace },
		// 设置文本段间距
		{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(paragraphSpacing), &paragraphSpacing },
		// 设置段前间距
		{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(paragraphSpacing), &paragraphSpacing },
		// 设置首行缩进
		{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(headIndent), &headIndent }
	};
	// 通过设置项产生段落样式对象
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings , sizeof(settings)/sizeof(CTParagraphStyleSetting));
	CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attributedString, CFRangeMake(0, [contentStr length]), kCTParagraphStyleAttributeName, paragraphStyle);
	CFRelease(paragraphStyle);
	
	CGRect columnFrame = rect;
	columnFrame.size = CGSizeMake(self.layoutConfig.pageWidth, self.layoutConfig.pageHeight);
	//columnFrame = UIEdgeInsetsInsetRect(columnFrame, edgeInsets);
	CGMutablePathRef framePath = CGPathCreateMutable();
	CGPathAddRect(framePath, &CGAffineTransformIdentity, columnFrame);
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attributedString);
	CTFrameRef contentFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), framePath, NULL);
	CTFrameDraw(contentFrame, context);
	
	CFRelease(framesetter);
	CFRelease(contentFrame);
	CFRelease(framePath);
}

@end


#if 0

http://blog.csdn.net/fengsh998/article/details/8700627
http://www.padovo.com/blog/2013/01/31/study-coretext/

//CTParagraphStyleSpecifier
kCTParagraphStyleSpecifierAlignment = 0,                 //对齐属性
kCTParagraphStyleSpecifierFirstLineHeadIndent = 1,       //首行缩进
kCTParagraphStyleSpecifierHeadIndent = 2,                //段头缩进
kCTParagraphStyleSpecifierTailIndent = 3,                //段尾缩进
kCTParagraphStyleSpecifierTabStops = 4,                  //制表符模式
kCTParagraphStyleSpecifierDefaultTabInterval = 5,        //默认tab间隔
kCTParagraphStyleSpecifierLineBreakMode = 6,             //换行模式
kCTParagraphStyleSpecifierLineHeightMultiple = 7,        //多行高
kCTParagraphStyleSpecifierMaximumLineHeight = 8,         //最大行高
kCTParagraphStyleSpecifierMinimumLineHeight = 9,         //最小行高
kCTParagraphStyleSpecifierLineSpacing = 10,              //行距
kCTParagraphStyleSpecifierParagraphSpacing = 11,         //段落间距  在段的未尾（Bottom）加上间隔，这个值为负数。
kCTParagraphStyleSpecifierParagraphSpacingBefore = 12,   //段落前间距 在一个段落的前面加上间隔。TOP
kCTParagraphStyleSpecifierBaseWritingDirection = 13,     //基本书写方向
kCTParagraphStyleSpecifierMaximumLineSpacing = 14,       //最大行距
kCTParagraphStyleSpecifierMinimumLineSpacing = 15,       //最小行距
kCTParagraphStyleSpecifierLineSpacingAdjustment = 16,    //行距调整
kCTParagraphStyleSpecifierCount = 17,        //

对齐属性：
kCTLeftTextAlignment = 0,                //左对齐
kCTRightTextAlignment = 1,               //右对齐
kCTCenterTextAlignment = 2,              //居中对齐
kCTJustifiedTextAlignment = 3,           //文本对齐
kCTNaturalTextAlignment = 4              //自然文本对齐
段落默认样式为
kCTNaturalTextAlignment

kCTParagraphStyleSpecifierParagraphSpacingBefore
段前间距设置代码（段与段之间）：

基本书写方向代码：
kCTParagraphStyleSpecifierBaseWritingDirection
kCTWritingDirectionNatural = -1,            //普通书写方向，一般习惯是从左到右写
kCTWritingDirectionLeftToRight = 0,         //从左到右写
kCTWritingDirectionRightToLeft = 1          //从右到左写

#endif

