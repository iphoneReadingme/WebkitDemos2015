


#import "DemoSpriteKitView.h"


///< DemoSpriteKitView
#pragma mark - == DemoSpriteKitView

@interface DemoSpriteKitView()

@property (nonatomic, retain) UIView                  *containerView;
@property (nonatomic, retain) UIButton                *startButton;
@property (nonatomic, retain) UIButton                *stopButton;

@end



///< DemoSpriteKitView
@implementation DemoSpriteKitView

-(void)dealloc
{
	[self releaseImageViews];
	[self releaseButtons];
	
	[super dealloc];
}

- (instancetype)initWithFrame:(CGRect)rect
{
	self = [super initWithFrame:rect];
	if (self)
	{
		self.accessibilityLabel = @"DemoSpriteKitView";
		
		[self addsubViews];
		
		[self didThemeChange];
		[self onChangeFrame];
		
		self.layer.borderColor = [UIColor redColor].CGColor;
		self.layer.borderWidth = 2;
	}
	
	return self;
}

- (void)releaseImageViews
{
}

- (void)releaseButtons
{
	
	[_startButton release];
	_startButton = nil;
	
	[_stopButton release];
	_stopButton = nil;
}

- (void)addsubViews
{
	
	[self addContainerViewObj];
	[self addButtonViews];
	
}

- (void)addContainerViewObj
{
	UIView *pView = [[UIView alloc] initWithFrame:[self bounds]];
	pView.backgroundColor = [UIColor clearColor];
	pView.accessibilityLabel = @"self_containerView";
	[self addSubview:pView];
	
	pView.layer.borderColor = [UIColor blueColor].CGColor;
	pView.layer.borderWidth = 4;
	_containerView = pView;
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
	self.startButton = pButton;
	[self addSubview:pButton];
	
	nIndex = 1;
	pButton = [self createButton:nIndex withName:@"UC.NoImageEdu.stopButton"];
	[pButton setFrame:btnRect];
	[pButton setTitle:@"停止" forState:UIControlStateNormal];
	self.stopButton = pButton;
	[self addSubview:pButton];
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
		NSLog(@"====【开始】====");
	}
	else if (nTag == 1)
	{
		NSLog(@"====【停止】====");
	}
}

- (void)didThemeChange
{
	self.backgroundColor = [UIColor lightGrayColor];
	
	[_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	_startButton.layer.borderColor = [UIColor redColor].CGColor;
	_startButton.layer.borderWidth = 2;
	_stopButton.layer.borderColor = [UIColor redColor].CGColor;
	_stopButton.layer.borderWidth = 2;
	
}

- (void)onChangeFrame
{
	CGRect rect = CGRectMake(100, 0, 0, 80);
	
	rect.size.height = 44;
	rect.size.width = 60;
	rect.origin.x = 100;
	rect.origin.y = 44;
	[_startButton setFrame:rect];
	
	rect.origin.x += rect.size.width + 40;
	[_stopButton setFrame:rect];
}


@end
