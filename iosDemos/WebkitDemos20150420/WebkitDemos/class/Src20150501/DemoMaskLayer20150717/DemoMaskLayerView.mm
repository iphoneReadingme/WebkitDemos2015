

#import "ResManager.h"
#import "DemoCustomView.h"
#import "DemoMaskLayerView.h"


#define kMainViewWidth            300
#define kMainViewHeight           64


@interface DemoMaskLayerView()

@property (nonatomic, retain) UIButton                *startButton;
@property (nonatomic, retain) UIButton                *stopButton;
@property (nonatomic, retain) UIImageView             *maskView;
@property (nonatomic, retain) UIImageView             *maskView2;
@property (nonatomic, retain) DemoCustomView          *custView;
@end

@implementation DemoMaskLayerView

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
		self.accessibilityLabel = @"Demo3DPerspectiveView";
		
		[self handleMask1];
		[self handleMask2];
		[self addChannelMaskView2];
		[self addsubViews];
		
		[self didThemeChange];
		[self onChangeFrame];
	}
	
	return self;
}

- (void)releaseImageViews
{
	[_maskView release];
	_maskView = nil;
	
	[_startButton release];
	_startButton = nil;
	
	[_stopButton release];
	_stopButton = nil;
}

#pragma mark -==左侧掩码
- (void)handleMask1
{
	UIView* bg1 = [[UIView alloc] initWithFrame:CGRectMake(10, 100, kMainViewWidth, kMainViewHeight)];
	bg1.accessibilityLabel = @"Mask1_background_bg1";
	
	[self addSubview:bg1];
	[self getMaskImageView];
	[self updateChannelMaskImage:bg1];
	
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, kMainViewHeight-20, kMainViewWidth, 25)] autorelease];
	label.text = @"【1】左侧掩码test mask view";
	label.textColor = [UIColor redColor];
	label.backgroundColor = [UIColor clearColor];
	
	UIView* content = [[UIView alloc] initWithFrame:[bg1 frame]];
	content.backgroundColor = [UIColor blueColor];
	[content addSubview:label];
	content.accessibilityLabel = @"Mask1_background_Content";
	
	[content setFrame:[bg1 bounds]];
	[bg1 addSubview:content];
}

- (void)getMaskImageView
{
	CGRect maskRect = CGRectMake(0, 0, kMainViewWidth, kMainViewHeight);
	CGRect rect = maskRect;
	static UIImageView* maskView = nil;
	if (maskView == nil)
	{
		maskView = [[[UIImageView alloc] initWithFrame:rect] autorelease];
		
		_maskView = [maskView retain];
	}
	UIImage* pImage = resGetImage(@"NewsFlow/SiteNav/ChannelLabelMaskImage.png");
	//pImage = resGetImage(@"NewsFlow/Channels/ChannelLabelMaskImage.png");
	//rect.size = [pImage size];
	[_maskView setFrame:rect];
	_maskView.image = pImage;
}

- (void)updateChannelMaskImage:(UIView*)pView
{
	pView.layer.mask = _maskView.layer;
	
	pView.layer.borderColor = [UIColor redColor].CGColor;
	pView.layer.borderWidth = 1;
}

#pragma mark -==左右两侧掩码
- (void)handleMask2
{
	UIView* bg1 = [[UIView alloc] initWithFrame:CGRectMake(10,220, kMainViewWidth, kMainViewHeight)];
	bg1.backgroundColor = [UIColor clearColor];
	bg1.accessibilityLabel = @"Mask2_background_bg1";
	
	[self addSubview:bg1];
	
	[self addChannelMaskView];
	//[self performSelector:@selector(updateChannelMaskImage:) withObject:bg1 afterDelay:0];
	
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, kMainViewHeight-20, 800, 25)] autorelease];
	label.text = @"【2】左右两侧掩码test mask view【2】左右两侧掩码";
	label.textColor = [UIColor redColor];
	label.backgroundColor = [UIColor clearColor];
	
	UIScrollView* content = [[UIScrollView alloc] initWithFrame:[bg1 frame]];
	content.backgroundColor = [UIColor blueColor];
	[content addSubview:label];
	content.accessibilityLabel = @"Mask2_background_Content";
	
	content.contentSize = CGSizeMake(800, 0);
	
	[content setFrame:[bg1 bounds]];
	[bg1 addSubview:content];
	[self updateChannelMaskImage2:bg1];
}

- (void)updateChannelMaskImage2:(UIView*)pView
{
	pView.layer.mask = _maskView.layer;
	//pView.layer.mask = [_maskView2.layer copy];
	
	pView.layer.borderColor = [UIColor redColor].CGColor;
	pView.layer.borderWidth = 1;
}

- (void)addChannelMaskView
{
	UIImage* pImage = resGetImage(@"NewsFlow/Channels/ChannelLabelMaskImage.png");
	CGSize imgSize = [pImage size];
	pImage = [pImage stretchableImageWithLeftCapWidth:imgSize.width*0.5f topCapHeight:imgSize.height*0.5f];
	CGRect rect = CGRectMake(0, 0, kMainViewWidth, kMainViewHeight);
	//rect = CGRectMake(10,220, kMainViewWidth, kMainViewHeight);
	_maskView2 = [[[UIImageView alloc] initWithFrame:rect] autorelease];
	_maskView2.image = pImage;
	_maskView2.accessibilityLabel = @"Mask2_T_maskView2";
	[self addSubview:_maskView2];
}

- (void)addChannelMaskView2
{
	UIImage* pImage = resGetImage(@"NewsFlow/Channels/ChannelLabelMaskImage.png");
	CGSize imgSize = [pImage size];
	pImage = [pImage stretchableImageWithLeftCapWidth:imgSize.width*0.5f topCapHeight:imgSize.height*0.5f];
	CGRect rect = CGRectMake(0, [self bounds].size.height - kMainViewHeight - 20, kMainViewWidth, kMainViewHeight);
	
	UIImageView* g_maskView = [[[UIImageView alloc] initWithFrame:rect] autorelease];
	g_maskView.image = pImage;
	g_maskView.accessibilityLabel = @"Mask2_g_maskView";
	[self addSubview:g_maskView];
}

#if 1
- (void)updateChannelMaskPath:(UIView*)pView
{
	// Create a mask layer and the frame to determine what will be visible in the view.
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
	CGRect maskRect = CGRectMake(50, 50, 100, 50);
	
	// Create a path and add the rectangle in it.
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, nil, maskRect);
	
	// Set the path to the mask layer.
	[maskLayer setPath:path];
	
	// Release the path since it's not covered by ARC.
	CGPathRelease(path);
	
	// Set the mask of the view.
	pView.layer.mask = [maskLayer copy];
}
#endif

- (void)addsubViews
{
	[self addImageViews];
	
	[self addButtonViews];
	
	[self addDemoCustomView];
}

- (UIImageView*)createImageView
{
	UIImageView *pView = nil;
	
	pView = [[[UIImageView alloc] initWithFrame:[self bounds]] autorelease];
	pView.backgroundColor = [UIColor clearColor];
	[self addSubview:pView];
	
	return pView;
}

- (void)addImageViews
{
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
		//[self startAnimation];
		[_custView executeAnimation];
	}
	else if (nTag == 1)
	{
		//[self stopAnimation];
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

#define kImageViewWidth                       160
#define kImageViewTop                         50

- (void)onChangeFrame
{
	CGRect rect = CGRectMake(100, kImageViewTop, kImageViewWidth, 80);
	
	rect.size.height = 44;
	rect.size.width = 60;
	rect.origin.x = 100;
	rect.origin.y = 44;
	[_startButton setFrame:rect];
	
	rect.origin.x += rect.size.width + 40;
	[_stopButton setFrame:rect];
}

///< test View / CALayer frame,bounds,center
- (void)addDemoCustomView
{
	CGRect rect = CGRectMake(50, 250, 50, 80);
	DemoCustomView *cusView = [[DemoCustomView alloc] initWithFrame:rect];
	[self addSubview:cusView];
	
	_custView = cusView;
	//[cusView autorelease];
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
}

@end
