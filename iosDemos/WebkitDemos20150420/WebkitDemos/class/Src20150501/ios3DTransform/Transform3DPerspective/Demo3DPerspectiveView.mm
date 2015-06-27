

#import "Demo3DPerspectiveView.h"
#import "CATransform3DPerspect.h"


@interface Demo3DPerspectiveView()

@property (nonatomic, assign) BOOL                    continueAnimation;
@property (nonatomic, assign) CGFloat                 angle;

@property (nonatomic, retain) UIImageView             *imgView1;
@property (nonatomic, retain) UIImageView             *imgView2;
@property (nonatomic, retain) UIImageView             *imgView3;
@property (nonatomic, retain) UIImageView             *imgView4;
@property (nonatomic, retain) UIButton                *startButton;
@property (nonatomic, retain) UIButton                *stopButton;

@end

@implementation Demo3DPerspectiveView

-(void)dealloc
{
	[self stopAnimation];
	[self releaseImageViews];
	
	[super dealloc];
}

- (instancetype)initWithFrame:(CGRect)rect
{
	self = [super initWithFrame:rect];
	if (self)
	{
		self.backgroundColor = [UIColor lightGrayColor];
		self.accessibilityLabel = @"Demo3DPerspectiveView";
		
		[self addsubViews];
		
		[self didThemeChange];
		[self onChangeFrame];
	}
	
	return self;
}

- (void)releaseImageViews
{
	[_imgView1 release];
	_imgView1 = nil;
	
	[_imgView2 release];
	_imgView2 = nil;
	
	[_imgView3 release];
	_imgView3 = nil;
	
	[_imgView4 release];
	_imgView4 = nil;
	
	
	[_startButton release];
	_startButton = nil;
	
	[_stopButton release];
	_stopButton = nil;
}

- (void)addsubViews
{
	[self addImageViews];
	
	[self addButtonViews];
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
	_imgView1 = [[self createImageView] retain];
	_imgView2 = [[self createImageView] retain];
	_imgView3 = [[self createImageView] retain];
	_imgView4 = [[self createImageView] retain];
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
		[self startAnimation];
	}
	else if (nTag == 1)
	{
		[self stopAnimation];
	}
}

- (void)didThemeChange
{
//	UIImage *pImage = nil;
	
	//pImage = resGetImage(@"SmartNoimageEdu/iconBgImage.png");
	//_iconBgImgView.image = pImage;
	_imgView1.backgroundColor = [UIColor redColor];
	_imgView2.backgroundColor = [UIColor blueColor];
	_imgView3.backgroundColor = [UIColor magentaColor];
	_imgView4.backgroundColor = [UIColor purpleColor];
	
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
	rect.origin.x = 0.5 * ([self bounds].size.width - rect.size.width);
	[_imgView1 setFrame:rect];
	[_imgView2 setFrame:rect];
	[_imgView3 setFrame:rect];
	[_imgView4 setFrame:rect];
	
	rect.size.height = 44;
	rect.size.width = 60;
	rect.origin.x = 100;
	rect.origin.y = 44;
	[_startButton setFrame:rect];
	
	rect.origin.x += rect.size.width + 40;
	[_stopButton setFrame:rect];
}

#pragma mark -== 动画相关
- (void)startAnimation
{
	_continueAnimation = YES;
	
	[self performSelector:@selector(excuteAnimation) withObject:nil afterDelay:0.0f];
}

- (void)stopAnimation
{
	_continueAnimation = NO;
	//_angle = 0;
	[self.layer removeAllAnimations];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
}

- (void)excuteAnimation
{
	if (_continueAnimation)
	{
		_angle += 0.05;
		[self setCubeFlipAngle:_angle];
		
		[self performSelector:@selector(excuteAnimation) withObject:nil afterDelay:0.1f];
	}
}

- (void)setCubeFlipAngle:(float)angle
{
	CGFloat y = kImageViewTop;
	CATransform3D move = CATransform3DMakeTranslation(0, y, kImageViewWidth*0.5f);
	CATransform3D back = CATransform3DMakeTranslation(0, y, -kImageViewWidth*0.5f);
	
	CATransform3D rotate0 = CATransform3DMakeRotation(-angle, 0, 1, 0);
	CATransform3D rotate1 = CATransform3DMakeRotation(M_PI_2-angle, 0, 1, 0);
	CATransform3D rotate2 = CATransform3DMakeRotation(M_PI_2*2-angle, 0, 1, 0);
	CATransform3D rotate3 = CATransform3DMakeRotation(M_PI_2*3-angle, 0, 1, 0);
	
	CATransform3D mat0 = CATransform3DConcat(CATransform3DConcat(move, rotate0), back);
	CATransform3D mat1 = CATransform3DConcat(CATransform3DConcat(move, rotate1), back);
	CATransform3D mat2 = CATransform3DConcat(CATransform3DConcat(move, rotate2), back);
	CATransform3D mat3 = CATransform3DConcat(CATransform3DConcat(move, rotate3), back);
	
	CGFloat disZ = 500;
	_imgView1.layer.transform = CATransform3DPerspect(mat0, CGPointZero, disZ);
	_imgView2.layer.transform = CATransform3DPerspect(mat1, CGPointZero, disZ);
	_imgView3.layer.transform = CATransform3DPerspect(mat2, CGPointZero, disZ);
	_imgView4.layer.transform = CATransform3DPerspect(mat3, CGPointZero, disZ);
}

@end
