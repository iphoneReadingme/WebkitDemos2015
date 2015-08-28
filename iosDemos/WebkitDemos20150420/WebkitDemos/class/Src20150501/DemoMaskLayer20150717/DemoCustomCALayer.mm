

#import "DemoCustomCALayer.h"

@interface DemoCustomCALayer ()


@end

@implementation DemoCustomCALayer


- (void)dealloc
{
    [super dealloc];
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		//[self display];
	}
	
	return self;
}

+ (Class)layerClass
{
	return [DemoCustomCALayer class];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}

- (void)setPosition:(CGPoint)center
{
	[super setPosition:center];
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
}

- (void)display
{
	[super display];
}

- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key
{
	NSLog(@"adding animation: %@", [anim debugDescription]);
	[super addAnimation:anim forKey:key];
}

@end
