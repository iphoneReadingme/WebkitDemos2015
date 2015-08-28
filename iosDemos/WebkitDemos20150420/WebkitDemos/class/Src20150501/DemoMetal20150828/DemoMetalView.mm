

#import "DemoMetalView.h"


@interface DemoMetalView()

@end

@implementation DemoMetalView

-(void)dealloc
{
	[self releaseImageViews];
	
	[super dealloc];
}

- (instancetype)initWithFrame:(CGRect)rect
{
	self = [super initWithFrame:rect];
	if (self)
	{
		self.accessibilityLabel = @"DemoMetalView";
		
		[self addsubViews];
		
		[self didThemeChange];
		[self onChangeFrame];
	}
	
	return self;
}

- (void)releaseImageViews
{
	
}

- (void)addsubViews
{
	
	[self addButtonViews];
	
}

#pragma mark - ==按钮相关

- (void)addButtonViews
{
	UIButton* pButton = nil;
	
	CGRect btnRect = [self bounds];
	NSInteger nIndex = 0;
	
	///< ""
	pButton = [self createButton:nIndex withName:@"UC.NoImageEdu.startButton"];
	[pButton setFrame:btnRect];
	[pButton setTitle:@"开始" forState:UIControlStateNormal];
	//self.startButton = pButton;
	//[self addSubview:pButton];
	
	nIndex = 1;
	pButton = [self createButton:nIndex withName:@"UC.NoImageEdu.stopButton"];
	[pButton setFrame:btnRect];
	[pButton setTitle:@"停止" forState:UIControlStateNormal];
	//self.stopButton = pButton;
	//[self addSubview:pButton];
}

- (UIButton*)createButton:(NSInteger)nTag withName:(NSString*)pStrName
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button addTarget:self action:@selector(onButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
	button.tag = nTag;
	button.accessibilityLabel = pStrName;
	button.backgroundColor = [UIColor clearColor];
	
	return button;
}

- (void)onButtonClickEvent:(UIButton*)sender
{
	NSInteger nTag = sender.tag;
	if (nTag == 0)
	{
	}
	else if (nTag == 1)
	{
	}
}

- (void)didThemeChange
{
	self.backgroundColor = [UIColor lightGrayColor];
	
	//[_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	//[_stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
}

#define kImageViewWidth                       160
#define kImageViewTop                         50

- (void)onChangeFrame
{
	CGRect rect = CGRectMake(100, kImageViewTop, kImageViewWidth, 80);
	
	rect.size.height = 44;
	rect.size.width = 60;
	rect.origin.x = 100;
	rect.origin.y = 44;
	//[_startButton setFrame:rect];
	
	rect.origin.x += rect.size.width + 40;
	//[_stopButton setFrame:rect];
}

@end
