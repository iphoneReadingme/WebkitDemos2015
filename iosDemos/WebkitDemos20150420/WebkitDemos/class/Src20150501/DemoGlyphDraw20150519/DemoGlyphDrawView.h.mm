//
//  TView.m
//  TiledDemo
//
//  Created by yangcy on 11-2-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#include <unistd.h>
#import "DemoGlyphDrawView.h"
//#import "MTime.h"
#import <CoreText/CoreText.h>
#import <CoreText/CTFont.h>


CG_EXTERN void CGFontGetGlyphsForUnichars(CGFontRef, const UniChar[], const CGGlyph[], size_t);
//extern "C" void CGFontGetGlyphsForUnicharsEx(void* font, UniChar st[], CGGlyph gh[], int flag);


//#define CGFontGetGlyphsForUnichars CGFontGetGlyphsForUnicharsEx


NSString* g_str_list[] = 
{
	@"极速之旅！点击此处下载热烈庆祝中国共产党建党90周年搜狐搜狗输入法浏览器地图邮件！金吉列参赞高峰讲坛！工薪阶层留学美国2011世界大学排名北大千人私募！邮箱爆料新的淘汰数据，这款人人喊打的浏览[推荐]如何从煤矿工成为程序员 ——手机QQ浏览器创新大赛火热启动相连接的适配器。新型的机顶盒遥控摩托罗拉展示其流媒体机顶盒股民遭遇虚假网站 连续三次被骗43近日已将一涉嫌股票诈骗的犯罪团伙隐形武器或无辐射风险的医疗影像技0元购机不是梦 魅族M9合约机来袭新疆昭苏现浓雾升天云海奇观 持续小贝携美女造势 钦点奥运火炬手帕勒莫退役飙泪 那英朋克裙凌乱修身短裤混搭加分 上演帅气街头风越南愈加频繁宣示对占据的南沙岛礁“支付宝股权转移真相浮现，就圣的：仓颉造字、",
	@"新闻戴口罩受访附近海域拥有无可争辩的主权。中国男孩被老师胶带封嘴听课爆强宝宝的搞笑霹雳舞墨西哥雪地捕获外星人婴儿遵义打出上访者被劳教横幅 恐吓上访脾虚脸黄腰痛找德良方巨蟒吞鳄鱼肚皮被撑破周恩来智慧外交风云录谈一谈你是否遭遇过职场中的性别清华：感谢重庆把宝贵的精神送进刘嘉玲助阵杨澜新店AMD G系列嵌入式APU升级新步进 请选择搜索影片科林-施特劳斯 格雷格-施特S大卫-札亚斯按类型动作战争恐怖剧情喜剧文...约翰尼-德普愿嫁金龟婿您的主页(写下您的站点,带来意想不新闻概要部分(尽量简明概要):叙述完整.并附上相关资源,文档,为大家送上更无主稿件可能会被暂缓发表.订阅新闻新闻概要部分(尽量简明概要):[视频]高仿iPhone界面新高峰：采用史玉柱再次力",
	@"挺马云 指责批判者是霍炬：新浪微博你让我浑身发冷固态硬盘(SSD)产品已经开始逐渐普 毕昇活字、方正排AMD计划年底淘汰六核羿龙CPU 让越南武装舰船驱赶中国渔船 拖曳倒 要坚持办案与管理两手抓、两手硬，做到重管理、敢管理、会管理，以科学管理保质量、促效率，下大力气推进审限内结案率的落实工作，促进刑事审判方面审判管理工作的科学规范化。最高人民法院审判委员会专职委员黄尔梅主持研讨班开班式。纵览 Mac 运行全局的 Mission Control、应用程序新家园 Launchpad 以及经完全重新设计的 Mail 应用程序。 阅读更多信息: apple.com.cn/macosx 推进刑事和解工作，最大限度地实现被害方的合法权益，促进依法结案，事了、人和张军要求，各级法院都要增强审判管理意识。",

	@"Apple 今日发布了 iOS 5 预览，这是先进的移动操作系统的最新版本。它拥有 200 多项新功能，将于今年秋季上市，作为向 iPad、iPhone 和 iPod touch 用户提供的免费软件更新。iOS 5 的新功能包括：通知中心，这项创新之举能让用户在一个位置轻松浏览和管理通知，免受干扰；iMessage，这项新的信息服务让你在所有 iOS 5 装置间发送文本消息、照片和视频；以及报刊杂志功能，提供了订购和管理报刊杂志的全新途径。有了 iOS 5，iPad、iPhone 和 iPod touch 用户开箱即可激活并设置新购的 iOS 装置，同时以无线方式获得软件更新，这些都无须使用电脑。 阅读更多信息: apple.com.cn/ios/\r\nMac OS X Lion 将于 7 月在 Mac App Store 推出2011 年 6 月 Apple 今日宣布，Mac OS X Lion 将作为先进的电脑操作系统的第八次重大发布，于 7 月在 Mac App Store 供用户下载。OS X Lion 提供 250 多项新功能，包括 Multi-Touch 手势、全系统支持的全屏应用程序、",
	@"法制网成都6月12日电 记者马利民 最高人民法院副院长张军今天在全国法院贯彻刑法修正案(八)研讨班上强调，人民法院要准确适用刑法修正案(八)的相关规定，对于危害国家安全、恐怖组织犯罪、“黑恶”势力犯罪等严重危害社会秩序和人民生命财产安全的犯罪分子，尤其对于极端仇视国家和社会，以不特定人为侵害对象，所犯罪行特别严重的犯罪分子，该依法重判的坚决重判，该依法判处死刑立即执行的决不手软。对于累犯以及因故意杀人、强奸、抢劫等严重危害社会治安的暴力性犯罪被判处死缓的，视情况可依法同时决定限制减张军强调，刑事审判深入推进社会矛盾化解，要正确认识附带民事诉讼的社会意义，切实把握社会政策、刑事政策的导向，着力开展刑事审判矛盾化解工作，加大附带民事诉讼调解工作的力度，推行以奖惩机制促进矛盾化解工作，通过加强指导、深入研讨、结合本地和个案实际，妥善处理损害赔偿问题，有效化解矛盾纠纷，积极探索、",
	@"记者通过暗访调查发现市民反映的情况基本属实。记者根据市民提供的线索找到了这家位于南京江宁湖熟宋家边的黑作坊，发现这是一处十分隐蔽的地方。村里人告诉记者，常常看到有拉着鸭子的车在这里进进出出。记者还没靠近，就有一股浓烈的鸭臊味混着松香味还有焦臭味扑面而来。记者看到在作坊门口停放的一辆农用车上，已经放着近百只等待被宰杀的活鸭。作坊内几名工人正忙着手中的活。记者上前打听这些鸭子是从哪里来的。一名工人支支吾吾地说了一句：“从附近农民家里收购来的。”然而记者表示想看一下这些鸭子的防疫证明时，工人称他们不知道有什么证明。\r\n\t记者在屋内看到灶台锅里烧满一锅黑褐色液体。原来，加工鸭子时，那些不易剔除干净的小毛在这个锅里“打个滚”，出来的便是一只白白嫩嫩，连细毛都没有的“白胖鸭”。记者问工人锅里黑褐色液体是什么，工人实话实说的告诉记者是松香，因为 “这样拔毛干净”。工人还表示平时不怎么用，只是加工量增大的时候，偶尔用一下提高效率。毕竟这样可以保证每只鸭子在经过拔毛后表皮的光滑。",
	@"未来到这个世界之前，来自云贵川地区的29名婴儿的命运便早已注定。\r\n\t没办法，这或许是目前能给孩子们找到的最好归宿。”聊城市刑警支队长殷广国长叹一声。\r\n\t日前，由公安部挂牌督办、聊城警方侦破的两起重大贩婴团伙案相继审理完毕。涉案人员分别被判处无期至一年半不等刑期。然而，被解救出来的29名婴儿，却因为无法找到亲生父母，仍旧只能继续寄养在买主家里，等待未知的命运。\r\n\t有家难回的不只他们：2009年10月29日，公安部在其网站上公布了首批60名已被解救的未查清身源被拐儿童信息。截至今年6月，仅有6名孩子顺利回家。剩下的54名孩子，仍在苦寻回家之路。",
	@"2009年7月底，聊城市公安局刑警支队接群众举报：自2008年10月以来，犯罪嫌疑人东昌府人卢某伙同他人多次从四川等地向山东贩卖婴儿。\r\n\t这起被命名为“8-26”重大贩婴团伙案的案件，随后被公安部列为全国“打拐”专项行动挂牌督办案件。奔走四川凉山、东营、潍坊等地，聊城警方抽调精干力量组成的专案组，经过一年多的侦查，查明卢某等人结伙或伙同他人，以出卖为目的，通过四川当地联系人，在云、贵、川等地收络婴儿送到聊城等地贩卖，并最终将15名犯罪嫌疑人一举抓获，解救被贩卖婴儿14名。其中，5名犯罪嫌疑人来自云南、四川两省。\r\n\t主犯卢某日前被法院以拐卖儿童罪判处无期徒刑，这在省内同类案件中是量刑最重的一个。”专案组副组长、聊城刑警支队长殷广国说。",
};


@implementation DemoGlyphDrawView


//NSTimer* g_timer = nil;
bool g_drawing = NO;
int	g_nDrawIndex = 0;


-(id)initWithFrame:(CGRect)frame
{
	[super initWithFrame:frame];
	
	
	NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
	g_nDrawIndex = [user integerForKey:@"DrawIndex"];
	//printf("g_nDrawIndex = %d\r\n", g_nDrawIndex);
	
	//[user setInteger:g_nDrawIndex+1 forKey:@"DrawIndex"];
	//[user synchronize];
	
	return self;
}

-(void)dealloc
{
	
	[super dealloc];
}

-(void)drawContext:(CGRect)rect context:(CGContextRef)context
{
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat colors[] =
	{
		204.0 / 255.0, 224.0 / 255.0, 244.0 / 255.0, 1.00,
		229.0 / 255.0, 56.0 / 255.0, 15.0 / 255.0, 1.00,
		0.0 / 255.0,  50.0 / 255.0, 126.0 / 255.0, 1.00,
	};
	
	CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	CGColorSpaceRelease(rgb);
	
	CGPoint start = CGPointMake(0, 0);
	CGPoint end = CGPointMake(self.frame.size.width, self.frame.size.height);
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation);
	
	CGGradientRelease(gradient);
}

void iDrawImage(CGContextRef cg, CGRect rect, CGImageRef img)
{
	CGContextScaleCTM (cg, 1.0, -1.0); 
	rect.origin.y = -rect.origin.y-rect.size.height;
	CGContextDrawImage(cg,rect,img);
	CGContextScaleCTM (cg, 1.0, -1.0); 
}

-(void)dump
{
	NSLog(@"TView: frame:%@ bounds:%@ transform:%@", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds), NSStringFromCGAffineTransform(self.transform));
}

-(void)drawInRect:(CGContextRef)context rect:(CGRect)rect string:(NSString*)str withFont:(UIFont *)font
{
	[str drawInRect:rect withFont:font];
}

-(void)drawAtPoint:(CGContextRef)context rect:(CGRect)rect string:(NSString*)str withFont:(UIFont *)font
{
	//[str drawAtPoint:rect.origin withFont:font];
	
	int len = [str length];
	NSRange aRange = NSMakeRange(0, 17);
	CGPoint ptStart = rect.origin;
	for (int i = 0; i < 20; ++i)
	{
		if ((aRange.location + aRange.length) >= len)
		{
			break;
		}
		
		NSString* s = [str substringWithRange:aRange];
		CGSize sz = [s drawAtPoint:ptStart withFont:font];
		aRange.location += aRange.length;
		ptStart.y += sz.height;
	}
}

#define			FONT_NAME		"STHeitiSC-Light"
#define			FONT_NAME_BOLD	"STHeitiTC-Medium"
#define			FONT_NAME_EN	"Helvetica"
#define			FONT_NAME_CN	"HiraKakuProN-W3"

CGSize DrawText(CGContextRef cg, int x, int y, NSString* str)
{
	CGSize sz = CGSizeMake(300, 22);
	
	int len = [str length];
	unichar uniChar[512] = { 0 };
	CGGlyph glyphBuf[512] = { 0 };
	
	[str getCString:(char *)uniChar maxLength:510 encoding:NSUTF16StringEncoding];
	
	CGFontRef fontRef = CGFontCreateWithFontName (CFSTR(FONT_NAME));
	CGContextSetFont(cg, fontRef);
	CGFontGetGlyphsForUnichars(fontRef, uniChar, glyphBuf, 510);
	CGContextShowGlyphsAtPoint (cg, x, y, glyphBuf, len);
	
	//CGPoint pt = CGContextGetTextPosition(cg);
	//sz = CGSizeMake(pt.x - x, pt.y - y);
	
	
	return sz;
}

-(void)showAtPoint:(CGContextRef)context rect:(CGRect)rect string:(NSString*)str withFont:(UIFont *)font
{
	CGContextSaveGState(context);

	CGContextSelectFont(context, FONT_NAME_CN, 18.0, kCGEncodingMacRoman);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
	
	/*
	const char* s = [str UTF8String];
	int len = [str length];
	CGContextShowTextAtPoint(context, rect.origin.x, rect.origin.y+20, s, len);
	CGContextShowTextAtPoint(context, 100, 100, "Hello!", 6);
	 */
	
	int len = [str length];
	NSRange aRange = NSMakeRange(0, 17);
	CGPoint ptStart = rect.origin;
	ptStart.y += 20;
	for (int i = 0; i < 20; ++i)
	{
		if ((aRange.location) >= len)
		{
			break;
		}
		
		if ((aRange.location + aRange.length) >= len)
		{
			aRange.length = len - aRange.location;
		}
		
		NSString* s = [str substringWithRange:aRange];
		//CGSize sz = [s drawAtPoint:ptStart withFont:font];
		CGSize sz = DrawText(context, ptStart.x, ptStart.y, s);
		aRange.location += aRange.length;
		ptStart.y += sz.height;
	}
	
	
	CGContextRestoreGState(context);
}

-(void)drawCTFrame:(CGContextRef)context rect:(CGRect)rect string:(NSString*)str withFont:(UIFont *)font
{
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, self.frame.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	//CTFontRef font = CTFontCreateWithName(CFSTR("Georgia"), 15, NULL);
	
	// Initialize a graphics context and set the text matrix to a known value.
	//CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]
	//									  graphicsPort];
	//CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	// Initialize a rectangular path.
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = CGRectMake(10.0, 10.0, 300.0, 420.0);
	CGPathAddRect(path, NULL, bounds);
	
	CTFontRef font1 = CTFontCreateWithName(CFSTR("Georgia"), 18, NULL);
	font1 = CTFontCreateCopyWithSymbolicTraits(font1, 0.0, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
	
	// Initialize an attributed string.
	//CFStringRef string = CFSTR("百度知道 We hold this truth to be self-evident, that everyone is created equal.");
	CFStringRef string = CFSTR("极速之旅！点击此处下载热烈庆祝中国共产党建党90周年搜狐搜狗输入法浏览器地图邮件！金吉列参赞高峰讲坛！工薪阶层留学美国2011世界大学排名北大千人私募！邮箱爆料新的淘汰数据，这款人人喊打的浏览[推荐]如何从煤矿工成为程序员 ——手机QQ浏览器创新大赛火热启动相连接的适配器。新型的机顶盒遥控摩托罗拉展示其流媒体机顶盒股民遭遇虚假网站 连续三次被骗43近日已将一涉嫌股票诈骗的犯罪团伙隐形武器或无辐射风险的医疗影像技0元购机不是梦 魅族M9合约机来袭新疆昭苏现浓雾升天云海奇观 持续小贝携美女造势 钦点奥运火炬手帕勒莫退役飙泪 那英朋克裙凌乱修身短裤混搭加分 上演帅气街头风越南愈加频繁宣示对占据的南沙岛礁“支付宝股权转移真相浮现，就圣的：仓颉造字、");
	string = (CFStringRef)str;
	int len = CFStringGetLength(string);
	
	CFMutableAttributedStringRef attrString =
	CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFAttributedStringReplaceString (attrString,
									 CFRangeMake(0, 0), string);
	
	// Create a color and add it as an attribute to the string.
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	//CGFloat components[] = { 1.0, 0.0, 0.0, 0.8 };
	//CGColorRef red = CGColorCreate(rgbColorSpace, components);
	CGColorSpaceRelease(rgbColorSpace);
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, len),
								   kCTForegroundColorAttributeName, [UIColor cyanColor].CGColor);
	
	CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attrString, CFRangeMake(0, len), 
								   kCTFontAttributeName, font1);
	
	// Create the framesetter with the attributed string.
	CTFramesetterRef framesetter =
	CTFramesetterCreateWithAttributedString(attrString);
	CFRelease(attrString);
	
	// Create the frame and draw it into the graphics context
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
												CFRangeMake(0, 0), path, NULL);
	CFRelease(framesetter);
	CTFrameDraw(frame, context);
	CFRelease(frame);
	
	
	CGContextRestoreGState(context);
}

-(void)drawRect:(CGRect)rect
{
//	[self dump];
	//NSLog(@"TView drawRect:%@", NSStringFromCGRect(rect));
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	//[self drawContext:rect context:context];
	
	CGContextClearRect(context, rect);
	
	static int index = 0;
	
	CGContextSetFillColorWithColor(context, [UIColor cyanColor].CGColor);
	NSString* str = g_str_list[index%5];
	//NSString* str = g_str_list[index%5];
	
	
	UIFont* font = [UIFont systemFontOfSize:18.0];

	
//	if (NO == g_drawing)
//	{
//		CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
//		CGRect rcText = CGRectMake(15.0, 5.0, 300.0, 420.0);
//		[self drawInRect:context rect:rcText string:@"Waiting..." withFont:[UIFont systemFontOfSize:35.0]];
//		return;
//	}
	
	CGRect rcText = CGRectMake(5.0, 5.0, 320.0, 420.0);
	NSString* name = nil;
	
	uint64_t spend = 0;
	//MTime tm;
	uint64_t ut1 = 0;// MTime::getMicroSecond();
	g_nDrawIndex = 2;
	switch (g_nDrawIndex%4)
	{
		case 0:
		{
			name = @"drawInRect";
			[self drawInRect:context rect:rcText string:str withFont:font];
			break;
		}
			
		case 1:
		{
			name = @"drawAtPoint";
			[self drawAtPoint:context rect:rcText string:str withFont:font];
			//[self showAtPoint:context rect:rcText string:str withFont:font];
			//[self showAtPoint:context rect:rcText string:@"发布了" withFont:font];
			//DrawText(context, rcText.origin.x, rcText.origin.y, @"发布了");
			break;
		}
			
		case 2:
		{
			name = @"showGlyphsAtPoint";
			[self showAtPoint:context rect:rcText string:str withFont:font];
			break;
		}
			
		case 3:
		{
			name = @"drawCTFrame";
			[self drawCTFrame:context rect:rcText string:str withFont:font];
			break;
		}
	}
			
	uint64_t ut2 = 0;// MTime::getMicroSecond();
	spend = ut2 - ut1;
	
	//const wchar_t* p = L"发布了";
	unsigned long time = 0;//MTime::highGetTime();
	static unsigned long _lastTime = time; 
	static int _lastIndex = index;
	
	static int framePerSecond = 0;
	if ((time - _lastTime) >= 2000)
	{
		framePerSecond = (index - _lastIndex) * 1000 / (time - _lastTime);
		
		_lastTime = time;
		_lastIndex = index;
	}
	
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextFillRect(context, CGRectMake(0, 425, 320, 40));
	CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
	//NSString* info = [NSString stringWithFormat:@"%@:%.04f sec. [%d fps]", name, spend/1000000.0, framePerSecond];
	NSString* info = [NSString stringWithFormat:@"%@:%5.04f sec.", name, spend/1000000.0];
	[info drawInRect:CGRectMake(15.0, 425, 300.0, 40)  withFont:[UIFont systemFontOfSize:20.0]];
	NSLog(@"%@", info);
	
	if (0 == index)
	{
		//printf("%s\r\n", [info UTF8String]);
		printf("%s   ", [info UTF8String]);
		if (3 == g_nDrawIndex%4)
		{
			printf("\r\n");
		}
		fflush(stdout);
		
		
		NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
		[user setInteger:g_nDrawIndex+1 forKey:@"DrawIndex"];
		[user synchronize];
		
	}	
	
	index ++;
}


- (void)updateTime:(NSTimer *)timer {
	
	g_drawing = YES;
	[self setNeedsDisplay];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	if ((point.x > 260) && (point.y < 60))
	{
		exit(0);
	}
	
	if (touch.tapCount == 2)
	{
		
		/*
		if (nil == g_timer)
		{
			g_timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];    
		}
		else 
		{
			[g_timer invalidate];
			g_timer = nil;
		}*/
		
		[self setNeedsDisplay];


	}
	
}


@end
