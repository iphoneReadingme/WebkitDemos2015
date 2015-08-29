

#import <SpriteKit/SpriteKit.h>
#import "HelloSceneNode.h"
#import "DemoSceneView.h"


@interface DemoSceneView()

@property (nonatomic, retain) SKView * spriteView;
@property (nonatomic, retain) HelloSceneNode *helloNode;

@end


@implementation DemoSceneView

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
		self.accessibilityLabel = @"DemoSceneView";
		
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
	[_spriteView release];
	_spriteView = nil;
	
	[_helloNode release];
	_helloNode = nil;
}

- (void)releaseButtons
{
}

- (void)addsubViews
{
	
	[self addButtonViews];
	
}

#pragma mark - ==按钮相关

- (void)addButtonViews
{
	SKView * spriteView =[[SKView alloc] initWithFrame:[self bounds]];
	spriteView.showsDrawCount = YES; ///< 使用多少绘画传递来渲染内容（越少越好）
	spriteView.showsNodeCount = YES; ///< 显示了多少个节点
	spriteView.showsFPS = YES;  ///< 最重要的一块信息是帧率（spriteView.showsFPS）
	
	[self addSubview:spriteView];
	_spriteView = spriteView;
	
	HelloSceneNode *hello = [[HelloSceneNode alloc] initWithSize:CGSizeMake(300, 400)];
	[spriteView presentScene:hello];
	
	_helloNode = hello;
}

- (void)didThemeChange
{
	self.backgroundColor = [UIColor lightGrayColor];
	
}

- (void)onChangeFrame
{
	CGRect rect = CGRectMake(100, 0, 0, 80);
	
	rect.size.height = 44;
	rect.size.width = 60;
	rect.origin.x = 100;
	rect.origin.y = 44;
	
}

- (void)updateScaleMode:(NSInteger)scaleMode
{
	static NSInteger i = 0;
	
	if (i < SKSceneScaleModeResizeFill)
	{
		i++;
	}
	else
	{
		i = 0;
	}
	scaleMode = i;
	[_helloNode updateScaleMode:(SKSceneScaleMode)scaleMode];
}

@end
