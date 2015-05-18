
#import <UIKit/UIKit.h>
#import "DemoRegularExpView.h"


///< 私有方法
@interface DemoRegularExpView()

@property (nonatomic, retain) UIView *bgAnimationView;

@property (nonatomic, retain) UILabel* chapterTitle;

- (void)addButtons;

@end

// =================================================================

@implementation DemoRegularExpView


- (void)forTest
{
	// for test
	self.backgroundColor = [UIColor brownColor];
	self.layer.borderWidth = 4;
	self.layer.borderColor = [UIColor colorWithRed:1.0 green:0 blue:1.0 alpha:1.0].CGColor;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code.
		[self forTest];
		self.backgroundColor = [UIColor grayColor];
		[self addSubViews:frame];
    }
    return self;
}

- (void)dealloc
{
	[self releaseObject];
	
	
    [super dealloc];
}

-(void)releaseObject
{
}

- (void)addSubViews:(CGRect)frame
{
	CGSize size = frame.size;
	size.height = 2048;
	self.contentSize = size;
	
	[self addButtons];
	
	CGRect rect = CGRectMake(20, 160, 280, 800);
	[self addTitleLabel:rect];
}

- (void)addBgView:(CGRect)frame
{
	CGRect rect = CGRectMake(20, 60, 100, 100);
	UIView* pView = [[[UIView alloc] initWithFrame:rect] autorelease];
	pView.backgroundColor = [UIColor whiteColor];
	[self addSubview:pView];
}

- (void)addTitleLabel:(CGRect)frame
{
	CGRect rect = frame;
	
	UILabel* titleLabel = [[UILabel alloc] initWithFrame:rect];
	titleLabel.font = [UIFont systemFontOfSize:17];
	titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	titleLabel.backgroundColor = [UIColor whiteColor];
	titleLabel.textAlignment = NSTextAlignmentLeft;///< 水平居左
	titleLabel.text = @"chapter title";
	titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	titleLabel.numberOfLines = 0;
	
	_chapterTitle = titleLabel;
	[self addSubview:titleLabel];
	
	[self setTextStyle];
}

NSString* kKeyString = @"These two documents provide the perfect starting point for iOS and Mac app development. Follow either road map to learn how to get and use Xcode to create your first app. You will learn how to use Xcode to test and debug your source code, analyze to improve your app’s performance, perform source control operations, archive your app, and submit your app to the App Store.\
fluid (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;(void)setAttributes:(NSDictionary*)attrs range:(NSRange)range;\
这是坐落在东北一一个叫小杨村的偏僻山村，四面环山。春夏之时满山花开，秋季挂满野果的果树映红整个山坡。这个小村大多数人都姓杨，几百年来都是如此的平静宁和。村民淳朴憨厚，与世无争。虽然生活过得紧紧巴巴，但他们过得却很快乐。\
这一年夏天，村儿里那条宽十多米自东向西横穿小村的小河突然一阵翻腾，一个光秃秃的脑袋冒了出来。看他的样子也就十一二岁，又黑又瘦的小脸天真透着点邪气，尤其是他的眼睛，大而明亮洋溢着精灵，但是随着他眼珠不停转动，又显示出这个小家伙的古怪。\
当他看见一名二十多岁，穿着短裤的女孩在不远处小路上经过时眼睛一亮，嘴角勾起一抹笑容，无论是谁看见他的笑容都会产生一种亲切感，那是一种来自内心的感觉。\
“杨美丽？”嘀咕完游到岸边穿上衣服悄悄跟在后面。在经过一片高粱地的时候，杨美丽突然钻了进去。";


- (void)setTextStyle
{
	//hyphenationFactor 连字符属性，取值 0 到 1 之间，开启断词功能
	
//	NSString *strstr = @"These two documents provide the perfect starting point for iOS and Mac app development. Follow either road map to learn how to get and use Xcode to create your first app. You will learn how to use Xcode to test and debug your source code, analyze to improve your app’s performance, perform source control operations, archive your app, and submit your app to the App Store.";
	
	NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	
	style.alignment = NSTextAlignmentLeft;
	style.firstLineHeadIndent = 0;
	style.lineSpacing = 7;
	style.paragraphSpacing = 5.6f;
	style.paragraphSpacingBefore = 0;
	style.hyphenationFactor = 0.9f;
	style.lineBreakMode = NSLineBreakByWordWrapping;
//	style.lineBreakMode = NSLineBreakByCharWrapping; ///< 连字符无效果
	
	//	style.headIndent = 10;//头部缩进，相当于左padding
	//	style.tailIndent = -10;//相当于右padding
	//	style.lineHeightMultiple = 1.5;//行间距是多少倍
	
	//NSMutableAttributedString设置属性
	UIFont* fontObj = nil;
	fontObj = [UIFont fontWithName:@"STHeitiSC-Medium" size:17];
	NSDictionary *attrs2 = @{
							 NSLigatureAttributeName: @(0),
							 NSParagraphStyleAttributeName:style,
							 //NSFontAttributeName:fontObj
							 NSFontAttributeName:[UIFont systemFontOfSize: 15]
							 //,NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)
							 };
	
	_chapterTitle.attributedText = [[[NSAttributedString alloc] initWithString: kKeyString attributes: attrs2] autorelease];
	
}

// =================================================================
#pragma mark- == Core Animation之多种动画效果
// 1、把图片移到右下角变小透明
// =================================================================
#pragma mark-
#pragma mark 创建按钮

- (UIButton*)createButton:(int)nTag withName:(NSString*)pStrName withTitle:(NSString*)pTitle
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[button addTarget:self action:@selector(onButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
	button.tag = nTag;
	button.accessibilityLabel = pStrName;
	[button setTitle:pTitle forState:UIControlStateNormal];
	
	button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
	
	[self addSubview:button];
	
	return button;
}

- (void)addButtons
{
	CGRect frame = [self bounds];
	frame.origin = CGPointZero;
	CGRect btnRect = CGRectMake(0, 0, 140, 64);
//	btnRect.origin.x = frame.size.width - btnRect.size.width;
	int nIndex = 1;
	UIButton* pBtn = nil;
	
	// "添加联系人"按钮
	btnRect = CGRectMake(0, 0, 80, 64);
	pBtn = [self createButton:nIndex withName:@"UIButtonTest1" withTitle:@"添加联系人"];
	[pBtn setFrame:btnRect];
	
	nIndex = 2;
	// "显示联系人"按钮
	btnRect.origin.x += 20 + btnRect.size.width;
	pBtn = [self createButton:nIndex withName:@"UIButtonTest2" withTitle:@"显示联系人"];
	[pBtn setFrame:btnRect];
	
	
	nIndex = 3;
	// "清空联系人"按钮
	btnRect.origin.x += 20 + btnRect.size.width;
	pBtn = [self createButton:nIndex withName:@"UIButtonTest2" withTitle:@"清空联系人"];
	[pBtn setFrame:btnRect];
	
	nIndex = 4;
	// "摇一摇"按钮
	btnRect = CGRectMake(0, 30+btnRect.size.height + btnRect.origin.y, 80, 64);
	pBtn = [self createButton:nIndex withName:@"UIButtonTest4" withTitle:@"摇一摇"];
	[pBtn setFrame:btnRect];
}

- (void)onButtonClickEvent:(UIButton*)sender
{
	NSInteger nTag = sender.tag;
	if (nTag == 1)
	{
		[self addPersons];
	}
	else if (nTag == 2)
	{
		[self showPersons];
	}
	else if (nTag == 3)
	{
		[self clearAllPersons];
	}
	else if (nTag == 4)
	{
		
	}
}

- (void)clearAllPersons
{
}

- (void)addPersons
{
}

- (void)showPersons
{
}

#pragma mark - == 摇一摇相关


@end


