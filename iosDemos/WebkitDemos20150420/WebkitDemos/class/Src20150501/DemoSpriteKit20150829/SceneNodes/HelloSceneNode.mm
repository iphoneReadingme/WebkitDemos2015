

#import "SpaceshipScene.h"
#import "HelloSceneNode.h"


@interface HelloSceneNode()

//@property (nonatomic, retain) SKView * spriteView;

@property (nonatomic, assign) BOOL contentCreated;

@end


/*
 ·      场景（SKScene对象），用来提供SKView对象要渲染的内容。
 ·      场景的内容被创建成树状的节点对象。场景是根节点。
 ·      在场景由视图呈现时，它运行动作并模拟物理，然后渲染节点树。
 ·      你可以通过子类化SKScene类创建自定义的场景。
 */
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
	///< 场景在绘制它的子元素之前用背景色绘制视图的区域。注意使用SKColor类创建color对象。事实上，SKColor不是一个类，它是一个宏，在iOS上映射为UIColor而在OS X上它映射为NSColor。它的存在是为了使创建跨平台的代码更容易。
	self.backgroundColor = [SKColor blueColor];
	
	///< 场景的缩放（scale）模式决定如何进行缩放以适应视图
	self.scaleMode = SKSceneScaleModeAspectFit;
	
	///< 在场景中显示Hello文本
	[self addChild:[self newHelloNode]];
}

- (void)updateScaleMode:(SKSceneScaleMode)scaleMode
{
	self.scaleMode = scaleMode;
	NSLog(@"%d", scaleMode);
}

- (SKLabelNode*)newHelloNode
{
	SKLabelNode * helloNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
	///< 用来搜索树中与名称相匹配的节点
	helloNode.name = @"helloNode";
	helloNode.text = @"Hello, World！";
	helloNode.fontSize = 42;
	helloNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
	return helloNode;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	SKNode *helloNode = [self childNodeWithName:@"helloNode"];
	if(helloNode != nil)
	{
		helloNode.name = nil;
		SKAction *moveUp = [SKAction moveByX:0 y:100.0 duration:0.5];
		SKAction *zoom = [SKAction scaleTo:2.0 duration:0.25];
		SKAction *pause = [SKAction waitForDuration:0.5];
		SKAction *fadeAway = [SKAction fadeOutWithDuration: 0.25];
		///< 从父节点中删除。
		SKAction *remove = [SKAction removeFromParent];
		SKAction * moveSequence = [SKAction sequence:@[moveUp, zoom, pause, fadeAway, remove]];
		
		///< wait 动作是一个特殊的动作,它通常仅在序列中使用。这个动作只是等待一段时间,然后 不做任何事情就结束。等待动作用于控制序列的定时。
		///< removeNode 动作是一个瞬时动作,所以它不花时间来执行。你可以看到,虽然这个动作是 序列的一部分,它不会出现在图 3-1 的时间轴上。作为瞬时动作,在淡入动作完成后它马上 开始和结束。然后序列也结束了。
		
		//[helloNode runAction:moveSequence];
		[helloNode runAction:moveSequence completion:^{
			
			[self didFinishedRunAction];
		}];
	}
}

- (void)didFinishedRunAction
{
	SKScene *spaceshipScene  = [[SpaceshipScene alloc] initWithSize:self.size];
	SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
	[self.view presentScene:spaceshipScene transition:doors];
	
}

@end
