

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
	spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-150);
	[self addChild:spaceship];
	
	[self addMakeRocks];
}

- (void)addMakeRocks
{
	SKAction * makeRocks = [SKAction sequence:@[
												[SKAction performSelector:@selector(addRock) onTarget:self],
												[SKAction waitForDuration:0.10 withRange:0.15]
												]];
	[self runAction:[SKAction repeatActionForever:makeRocks]];
}

static inline CGFloat skRandf()
{
	return rand()/(CGFloat)RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high)
{
	return skRandf()*(high - low) + low;
}

- (void)addRock
{
	SKSpriteNode *rock = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(8,8)];
	rock.position = CGPointMake(skRand(0, self.size.width),self.size.height-50);
	rock.name = @"rock";
	rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
	rock.physicsBody.usesPreciseCollisionDetection = YES;
	[self addChild:rock];
}

- (void)didSimulatePhysics
{
	///< 5. 实现场景中的didSimulatePhysics方法来当岩石移动到屏幕之外时移除它们。
	[self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop){
		if (node.position.y <0)
			[node removeFromParent];
	}];
}

- (void)updateScaleMode:(SKSceneScaleMode)scaleMode
{
	self.scaleMode = scaleMode;
	NSLog(@"%d", scaleMode);
}

- (SKSpriteNode*)newSpaceship
{
	SKSpriteNode *hull= [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size:CGSizeMake(64,32)];
	
	///< 添加物理体到飞船。飞船垂直坠落到屏幕下方。这是因为重力施加到飞船的物理体
	hull.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hull.size];
	///< 更改的newSpaceship方法来防止飞船受物理交互影响。
	hull.physicsBody.dynamic = NO;
	
	hull.texture = [self createTextureObj];
	[self spriteColorizingAnimation:hull];
	
	SKAction *hover= [SKAction sequence:@[
										  [SKAction waitForDuration:1.0],
										  [SKAction moveByX:100 y:50.0 duration:1.0],
										  [SKAction waitForDuration:1.0],
										  [SKAction moveByX:-100.0 y:-50 duration:1.0]]];
	[hull runAction:[SKAction repeatActionForever:hover]];
	
	///< 3. 添加代码到newSpaceship方法来添加灯光。
	SKSpriteNode *light1= [self newLight];
	light1.position = CGPointMake(-28.0, 6.0);
	[hull addChild:light1];
	
	SKSpriteNode *light2= [self newLight];
	light2.position = CGPointMake(28.0, 6.0);
	[hull addChild:light2];
	
	return hull;
}

- (SKTexture *)createTextureObj
{
	NSString *shortName = @"resource/Themes/Classic/Images/SpaceShip/Spaceship.png";
	SKTexture *texture = [SKTexture textureWithImageNamed:shortName];
	
	return texture;
}

- (SKSpriteNode *)newLight
{
	SKSpriteNode *light = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(8,8)];
	light = [self createSpriteObj];
	SKAction *blink= [SKAction sequence:@[
										  [SKAction fadeOutWithDuration:0.25],
										  [SKAction fadeInWithDuration:0.25]]];
	SKAction * blinkForever = [SKAction repeatActionForever:blink];
	[light runAction:blinkForever];
	
	return light;
}

///< 从存储在 bundle 中的图像创建一个纹理的精灵
///< 精灵的 size 属性指定精灵基准(无缩放)尺寸。当一个精灵使用代码清单 2-1 初始化时, 这个属性的值被初始化为于精灵的纹理的尺寸相等。
- (SKSpriteNode *)createSpriteObj
{
	///< resource/Themes/Classic/Images/SpaceShip/PlayIcon.png
	NSString *shortName = @"resource/Themes/Classic/Images/SpaceShip/PlayIcon.png";
	SKSpriteNode *spriteObj = [SKSpriteNode spriteNodeWithImageNamed:@"rocket.png"];
	spriteObj = [SKSpriteNode spriteNodeWithImageNamed:shortName];
	spriteObj.position = CGPointMake(100,100);
//	spriteObj.xScale = 8.0f/40;
//	spriteObj.yScale = 8.0f/40;
	spriteObj.size = CGSizeMake(8,8);
	//spriteObj.centerRect = CGRectMake(12.0/28.0,12.0/28.0,4.0/28.0,4.0/28.0); ///< 纹理可拉伸,所以 centerRect 参数拉伸区域（纹理区域【0， 1.0】）。
	//SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:@"stretchable_button.png"];
	//button.centerRect = CGRectMake(12.0/28.0,12.0/28.0,4.0/28.0,4.0/28.0);
	
	///< 对精灵着色
	//在把纹理应用到精灵之前,你可以使用 color 和 colorBlendFactor 属性对它着色。默认情 况下的颜色混合因子为 0.0,这表明纹理未经更改地使用。当你增加这个数字,更多的纹理颜 色就会被混合颜色替换。例如,在你的游戏中的怪物受到伤害时,你可能要添加一个红色的色调 (tint)给角色。
	spriteObj.color = [SKColor blueColor];
	spriteObj.colorBlendFactor = 0.5;
	
	///< 使用附加混合模式模拟发光
	spriteObj.blendMode = SKBlendModeAdd;
	
	return spriteObj;
}

- (void)spriteColorizingAnimation:(SKSpriteNode *)spriteObj
{
	SKAction *pulseRed = [SKAction sequence:@[
											  [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.15],
											  [SKAction waitForDuration:0.1],
											  [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
	[spriteObj runAction: pulseRed];
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
