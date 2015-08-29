


#import "DemoSceneView.h"


@interface DemoSceneView()

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
}

- (void)addsubViews
{
	
	[self addButtonViews];
	
}

#pragma mark - ==按钮相关

- (void)addButtonViews
{
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


@end
