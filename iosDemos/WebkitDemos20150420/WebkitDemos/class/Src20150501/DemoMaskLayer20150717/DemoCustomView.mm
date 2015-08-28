

#import "DemoCustomCALayer.h"
#import "DemoCustomView.h"

@interface DemoCustomView ()

@property (nonatomic, retain) CAGradientLayer *gradientBackgroundLayer;

@end

@implementation DemoCustomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        {
            UIView *maskView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
            maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
            [self addSubview:maskView];
        }
		
        {
//            CAGradientLayer *layer = (CAGradientLayer *)self.layer;
//            layer.startPoint = CGPointMake(0, 0);
//            layer.endPoint = CGPointMake(1, 1);
			
        }
    }
    return self;
}

- (void)dealloc
{
    [_gradientBackgroundLayer release];
    [super dealloc];
}

+ (Class)layerClass
{
	return [DemoCustomCALayer class];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}

- (void)setCenter:(CGPoint)center
{
	[super setCenter:center];
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
}

- (void)executeAnimation
{
	NSLog(@"【outside animation block: %@",
		  [self actionForLayer:self.layer forKey:@"position"]);
	
	[UIView animateWithDuration:0.3 animations:^{
		NSLog(@"inside animation block: %@",
			  [self actionForLayer:self.layer forKey:@"position"]);
	}];
}

@end
