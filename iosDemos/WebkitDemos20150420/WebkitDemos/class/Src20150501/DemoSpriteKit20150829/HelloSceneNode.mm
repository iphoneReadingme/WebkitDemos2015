

#import "HelloSceneNode.h"


@interface HelloSceneNode()

//@property (nonatomic, retain) SKView * spriteView;

@property (nonatomic, assign) BOOL contentCreated;

@end


@implementation HelloSceneNode

-(void)dealloc
{
	
	[super dealloc];
}

///< 每当视图呈现场景时，didMoveToView：方法都会被调用。但是，在这种情况下，场景的内容应只在场景第一次呈现时进行配置。因此，这段代码使用先前定义的属性（contentCreated）来跟踪场景的内容是否已经被初始化。
- (void)didMoveToView:(SKView *)view
{
	if (!self.contentCreated)
	{
		[self createSceneContents];
		self.contentCreated = YES;
	}
}

- (void)createSceneContents
{
	self.backgroundColor = [SKColor blueColor];
	self.scaleMode = SKSceneScaleModeAspectFit;
	[self addChild:[self newHelloNode]];
}

- (SKLabelNode*)newHelloNode
{
	SKLabelNode * helloNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
	helloNode.text = @"Hello, World！";
	helloNode.fontSize = 42;
	helloNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
	return helloNode;
}


@end
