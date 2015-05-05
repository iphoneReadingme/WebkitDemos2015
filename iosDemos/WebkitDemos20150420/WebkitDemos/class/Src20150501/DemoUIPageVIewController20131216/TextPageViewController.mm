

#import "NBBookLayoutConfig.h"
#import "DemoPageViewDrawText.h"
#import "TextPageViewController.h"
//#import "DemoViewCoreTextDrawMacroDefine.h"
#import "DemoTextPageMacroDefine.h"


#define kKeyMaxCountOfPage    100


#define kNumPageCharCount               190

@interface TextPageViewController ()
{
    NSUInteger _pageIndex;
}

@property (nonatomic, retain) DemoPageViewDrawText* pageView;
@property (nonatomic, copy) NSString * chapterText;

@end

@implementation TextPageViewController

+ (TextPageViewController*)getPageViewControllerForPageIndex:(NSUInteger)pageIndex withDelegate:(id<TextPageViewControllerDelegate>)delegate
{
    if (pageIndex < kKeyMaxCountOfPage)
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
	self.chapterText = nil;
}

- (id)initWithPageIndex:(NSInteger)pageIndex withDelegate:(id<TextPageViewControllerDelegate>)delegate
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
	
	if (_chapterText == nil)
	{
		self.chapterText = [self readPageTextFromFile];
	}
	
	[self addSubViewObject];
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
	NSInteger nCharCount = [_chapterText length];
	
	NSRange range = NSMakeRange(pageIndex*kNumPageCharCount, kNumPageCharCount);
	if (range.location + range.length < nCharCount)
	{
		NSString* chapterName = [NSString stringWithFormat:@"【共%d页】当前页面 第【%d】页，\n", [_chapterText length]/kNumPageCharCount, _pageIndex+1];
		
		NSString* message = [_chapterText substringWithRange:range];
		//pageContent = [NSMutableString stringWithFormat:@"%@", message];
		pageContent = [NSMutableString stringWithFormat:@"%@%@", chapterName, message];
		[pageContent appendFormat:@"\n%d", pageIndex+1];
	}
	
	return pageContent;
}

- (CGRect)getViewRect
{
	CGRect frame = [self.view bounds];
	
	frame.origin.y += kNavigationBarHeight;
	frame.size.height -= kStatusBarHeight + frame.origin.y;
	
	return frame;
}

- (void)addSubViewObject
{
	CGRect frame = [self getViewRect];
	
	NBBookLayoutConfig* layoutConfig = [NBBookLayoutConfig bookLayoutConfigWithFontSize:18 andWidth:frame.size.width andHeight:frame.size.height];
	
	self.pageView = [[[DemoPageViewDrawText alloc] initWithFrame:frame] autorelease];
	_pageView.layoutConfig = layoutConfig;
	
	[_pageView setPageContentText:[self getPageContentText:_pageIndex]];
	NSString* chapterName = [NSString stringWithFormat:@"【共%d页】当前页面 第【%d】页\n", [_chapterText length]/kNumPageCharCount, _pageIndex+1];
	[_pageView setCurChapterName:chapterName];
	[self showChapterName:chapterName];
	
	_pageView.layer.borderColor = [UIColor redColor].CGColor;
	_pageView.layer.borderWidth = 2;
	[self.view addSubview:_pageView];
}

- (void)showChapterName:(NSString*)chapterName
{
	if ([_delegate respondsToSelector:@selector(setCurChapterName:)])
	{
		[_delegate setCurChapterName:chapterName];
	}
}

@end

