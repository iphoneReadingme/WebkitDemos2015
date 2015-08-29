

#import "SpaceshipScene.h"


@interface SpaceshipScene()

@property (nonatomic, assign) BOOL contentCreated;

@end


@implementation SpaceshipScene

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
	self.backgroundColor = [SKColor blackColor];
	
	///< 场景的缩放（scale）模式决定如何进行缩放以适应视图
	self.scaleMode = SKSceneScaleModeAspectFit;
	
	///< 在场景中显示Hello文本
	//[self addChild:[self newSpaceship]];
	SKSpriteNode *spaceship = [self newSpaceship];
	spaceship.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-150);
	[self addChild:spaceship];
}

- (void)updateScaleMode:(SKSceneScaleMode)scaleMode
{
	self.scaleMode = scaleMode;
	NSLog(@"%d", scaleMode);
}

- (SKSpriteNode*)newSpaceship
{
	SKSpriteNode *hull= [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(64,32)];
	
	SKAction *hover= [SKAction sequence:@[
										  [SKAction waitForDuration:1.0],
										  [SKAction moveByX:100 y:50.0 duration:1.0],
										  [SKAction waitForDuration:1.0],
										  [SKAction moveByX:-100.0 y:-50 duration:1.0]]];
	[hull runAction:[SKAction repeatActionForever:hover]];
	
	SKSpriteNode *light1= [self newLight];
	light1.position = CGPointMake(-28.0, 6.0);
	[hull addChild:light1];
	
	SKSpriteNode *light2= [self newLight];
	light2.position = CGPointMake(28.0, 6.0);
	[hull addChild:light2];
	
	return hull;
}

- (SKSpriteNode *)newLight
{
	SKSpriteNode *light = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(8,8)];
	
	SKAction *blink= [SKAction sequence:@[
										  [SKAction fadeOutWithDuration:0.25],
										  [SKAction fadeInWithDuration:0.25]]];
	SKAction * blinkForever = [SKAction repeatActionForever:blink];
	[light runAction:blinkForever];
	
	return light;
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
		SKAction *fadeAway = [SKAction fadeOutWithDuration:0.25];
		///< 从父节点中删除。
		SKAction *remove = [SKAction removeFromParent];
		SKAction * moveSequence = [SKAction sequence:@[moveUp, zoom, pause, fadeAway, remove]];
		[helloNode runAction:moveSequence];
	}
}

@end
