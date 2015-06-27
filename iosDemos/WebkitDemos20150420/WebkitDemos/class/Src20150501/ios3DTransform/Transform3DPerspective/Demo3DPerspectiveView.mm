

#import "Demo3DPerspectiveView.h"


@implementation Demo3DPerspectiveView

-(void)dealloc
{
	
	[super dealloc];
}

- (instancetype)initWithFrame:(CGRect)rect
{
	self = [super initWithFrame:rect];
	if (self)
	{
		self.backgroundColor = [UIColor whiteColor];
		self.accessibilityLabel = @"Demo3DPerspectiveView";
		
	}
	
	return self;
}


@end
