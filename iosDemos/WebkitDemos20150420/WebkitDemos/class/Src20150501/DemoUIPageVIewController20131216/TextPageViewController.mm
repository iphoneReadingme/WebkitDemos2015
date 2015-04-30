

#import "NBBookLayoutConfig.h"
#import "DemoPageViewDrawText.h"
#import "TextPageViewController.h"
#import "DemoViewCoreTextDrawMacroDefine.h"


#define kKeyMaxCountOfPage    100

///< 数据文件路径
#define kHardcodeNovelDataPath           @"resource/Novel/part.txt"
#define kNumPageCharCount               300

@interface TextPageViewController ()
{
    NSUInteger _pageIndex;
}

@property (nonatomic, retain) NBBookLayoutConfig * layoutConfig;
@property (nonatomic, retain) DemoPageViewDrawText* pageView;
@property (nonatomic, copy) NSString * chapterText;

@end

@implementation TextPageViewController

+ (TextPageViewController*)getPageViewControllerForPageIndex:(NSUInteger)pageIndex
{
    if (pageIndex < kKeyMaxCountOfPage)
    {
        return [[[self alloc] initWithPageIndex:pageIndex] autorelease];
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
	self.pageView = nil;
}

- (id)initWithPageIndex:(NSInteger)pageIndex
{
    self = [super init];
    if (self)
    {
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
	
	self.layoutConfig = [NBBookLayoutConfig bookLayoutConfigWithFontSize:18 andWidth:320 andHeight:440];
	
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
		NSString* message = [_chapterText substringWithRange:range];
		pageContent = [NSMutableString stringWithFormat:@"　　[共%d页]当前页面 第[%d]页\n%@", nCharCount/kNumPageCharCount, pageIndex+1, message];
		[pageContent appendFormat:@"\n\n%d", pageIndex+1];
	}
	
	return pageContent;
}

- (CGRect)getViewRect
{
	CGRect frame = [self.view bounds];
	
	frame.origin.y += 44;
	frame.size.height -= 20 + frame.origin.y;
	
	return frame;
}

- (void)addSubViewObject
{
	CGRect frame = [self getViewRect];
	
	self.pageView = [[[DemoPageViewDrawText alloc] initWithFrame:frame] autorelease];
	_pageView.layoutConfig = _layoutConfig;
	
	[_pageView setText:[self getPageContentText:_pageIndex]];
	_pageView.layer.borderColor = [UIColor redColor].CGColor;
	_pageView.layer.borderWidth = 2;
	[self.view addSubview:_pageView];
}


@end

