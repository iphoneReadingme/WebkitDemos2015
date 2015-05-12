

#import "NBBookLayoutConfig.h"
#import "DemoPageViewDrawText.h"
#import "NBPageContainerViewController.h"
//#import "DemoViewCoreTextDrawMacroDefine.h"
#import "DemoTextPageMacroDefine.h"
//#import "NBPageItem.h"
//#import "NBChapterPagesInfo.h"



@interface NBPageContainerViewController ()
{
    NSInteger _pageIndex;
}

@property (nonatomic, retain) DemoPageViewDrawText  *pageView;
@property (nonatomic, retain) UILabel               *chapterTitle;

@end

@implementation NBPageContainerViewController

+ (NBPageContainerViewController*)getPageViewControllerForPageIndex:(NSInteger)pageIndex withDelegate:(id<NBPageContainerViewControllerDelegate>)delegate
{
    if (-1 < pageIndex && pageIndex < kKeyMaxCountOfPage)
    {
		return [[[self alloc] initWithPageIndex:pageIndex withDelegate:delegate] autorelease];
    }
    return nil;
}

+ (NSString *)displayName
{
	return @"书籍翻页动画";
}

- (void)dealloc
{
	[self releaseObject];
	
	[super dealloc];
}

- (void)releaseObject
{
	self.delegate = nil;
	self.pageView = nil;
}

- (id)initWithPageIndex:(NSInteger)pageIndex withDelegate:(id<NBPageContainerViewControllerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
		self.delegate = delegate;
        _pageIndex = pageIndex;
    }
    return self;
}

- (NSInteger)pageIndex
{
    return _pageIndex;
}

// (this can also be defined in Info.plist via UISupportedInterfaceOrientations)
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.accessibilityLabel = @"TextPageViewController.view";
	
	[self addSubViewObject];
	
	///< 分页
	NSString* chapterName = [self getChapterName:_pageIndex];
	[_pageView setPageContentText:[self getPageContentText:_pageIndex]];
	
	[_pageView setCurChapterName:chapterName];
	[self showChapterName:chapterName];
	[self.view addSubview:_pageView];
}

#pragma mark -
#pragma mark UIViewController delegate methods

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewWillDisappear:(BOOL)animated
{
//	[self releaseObject];
}

// =================================================================
#pragma mark -
#pragma mark 子视图对象


- (CGRect)getViewRect
{
	CGRect frame = [self.view bounds];
	
	frame.origin.y += kNavigationBarHeight;
	frame.size.height -= kStatusBarHeight + frame.origin.y;
	
	return frame;
}

- (CGRect)getPageViewFrame
{
	CGRect frame = [self getViewRect];
	
	CGRect titleRect = frame;
	titleRect.size.height = kChapterTitleHeight;
	
	CGRect pageRect = frame;
	
	pageRect.origin.y = titleRect.origin.y + titleRect.size.height;
	pageRect.size.height -= titleRect.size.height;
	
	return pageRect;
}

- (void)addSubViewObject
{
	CGRect frame = [self getViewRect];
	
	CGRect titleRect = frame;
	titleRect.size.height = kChapterTitleHeight;
	[self addTitleLabel:titleRect];
	
	CGRect pageRect = frame;
	pageRect.origin.y = titleRect.origin.y + titleRect.size.height;
	pageRect.size.height -= titleRect.size.height;
	
//	NBBookLayoutConfig* layoutConfig = [NBBookLayoutConfig bookLayoutConfigWithFontSize:18 andWidth:pageRect.size.width andHeight:pageRect.size.height];
	
	self.pageView = [[[DemoPageViewDrawText alloc] initWithFrame:pageRect] autorelease];
	_pageView.layoutConfig = [self getLayoutConfig];
	
	_pageView.layer.borderColor = [UIColor redColor].CGColor;
	_pageView.layer.borderWidth = 2;
}

- (void)addTitleLabel:(CGRect)frame
{
	CGRect rect = frame;
	
	UILabel* titleLabel = [[UILabel alloc] initWithFrame:rect];
	titleLabel.font = [UIFont systemFontOfSize:17];
	titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	titleLabel.backgroundColor = [UIColor whiteColor];
	titleLabel.textAlignment = NSTextAlignmentLeft;///< 水平居左
	titleLabel.text = @"chapter title";
	titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	titleLabel.numberOfLines = 0;
	
	_chapterTitle = titleLabel;
	[self.view addSubview:titleLabel];
}

- (void)showChapterName:(NSString*)chapterName
{
	if ([_delegate respondsToSelector:@selector(setCurChapterName:)])
	{
		[_delegate setCurChapterName:chapterName];
	}
	
	_chapterTitle.text = chapterName;
}

- (NSString*)getPageContentText:(int)pageIndex
{
	NSString* contentText = nil;
	
	if ([_delegate respondsToSelector:@selector(getPageContentText:)])
	{
		contentText = [_delegate getPageContentText:pageIndex];
	}
	
	return contentText;
}

- (NSString*)getChapterName:(int)pageIndex
{
	NSString* chapterName = nil;
	
	if ([_delegate respondsToSelector:@selector(getChapterName:)])
	{
		chapterName = [_delegate getChapterName:pageIndex];
	}
	
	return chapterName;
}

- (NBBookLayoutConfig*)getLayoutConfig
{
	NBBookLayoutConfig* config = nil;
	
	if ([_delegate respondsToSelector:@selector(getLayoutConfig)])
	{
		config = [_delegate getLayoutConfig];
	}
	
	return config;
}

@end

