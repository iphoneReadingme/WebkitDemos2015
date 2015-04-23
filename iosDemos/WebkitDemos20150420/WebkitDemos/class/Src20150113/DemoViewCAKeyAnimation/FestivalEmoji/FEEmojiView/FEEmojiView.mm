
/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: FEEmojiView.mm
 *
 * Description  : 节日表情图标视图
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-01-10.
 * History		: modify: 2015-01-10.
 *
 ******************************************************************************
 **/


#import "FEEmojiLabel.h"
#import "FEEmojiView.h"
//#import "UCUIKit/UCUIKit.h"
#import "NSMutableArray+ExceptionSafe.h"


#define kkeyTimes                             1

#define kkeyShowEmojiViewTime                 0.6f*kkeyTimes
#define kkeyHiddenEmojiViewTime               0.8f*kkeyTimes

///< 隐藏表情图标时，各个表情图标消失时最大时间间隔
#define kKeyOffsetTime                        0.3f*kkeyTimes

///< 0.5f 之后隐藏
#define kkeyWaitTimeBeforeHidden              0.8f


#define kAnimationKeyShowView                 @"kAnimationKeyShowView"
#define kAnimationKeyHiddenView               @"kAnimationKeyHiddenView"


@interface FEEmojiView ()

@property (nonatomic, retain) FEEmojiParameterInfo* parameterInfo;   ///< 表情图标参数信息
@property (nonatomic, retain) UIView *emojiContentView;

@end


@implementation FEEmojiView

- (id)initWithFrame:(CGRect)frame withData:(FEEmojiParameterInfo*)parameterInfo
{
    if (self = [super initWithFrame:frame])
	{
		self.hidden = YES;
		self.backgroundColor = [UIColor clearColor];
		self.parameterInfo = parameterInfo;
		
		[self addEmojiContentView];
		[self addLabels:parameterInfo];
    }
	
    return self;
}

- (void)dealloc
{
	_delegate = nil;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenFestivalEmojiView) object:nil];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayShow3DAnimation) object:nil];
	
	[_emojiContentView release];
	_emojiContentView = nil;
	
	[_parameterInfo release];
	_parameterInfo = nil;
	
	[super dealloc];
}

- (CGRect)getContentViewFrame
{
	CGRect bounds = [self bounds];
	CGRect rect = CGRectMake(0, 0, 320 * [self getUIScale], 320 * [self getUIScale]);
	rect.origin.x = 0.5f * (bounds.size.width - rect.size.width);
	rect.origin.y = 0.5f * (bounds.size.height - rect.size.height);
	
	return rect;
}

- (void)addEmojiContentView
{
	_emojiContentView = [[UIView alloc] initWithFrame:[self getContentViewFrame]];
	
	[self addSubview:_emojiContentView];
	
	_emojiContentView.accessibilityLabel = @"_emojiContentView";
}

- (void)addLabels:(FEEmojiParameterInfo*)parameterInfo
{
	for (NSString* temp in parameterInfo.coordinateArray)
	{
		CGPoint pt = CGPointFromString(temp);
		pt = [self getPointWith:pt with:0.5f];
		CGRect rect = CGRectMake(pt.x, pt.y, 32, 32);
		[self addLabelView:parameterInfo with:rect parent:_emojiContentView];
	}
}

- (void)addLabelView:(FEEmojiParameterInfo*)parameterInfo with:(CGRect)frame parent:(UIView*)parentView
{
	UILabel* titleLabel = [[[FEEmojiLabel alloc] initWithFrame:frame] autorelease];
	titleLabel.font = [UIFont systemFontOfSize:parameterInfo.fontSize*[self getUIScale]];
	//titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.text = parameterInfo.emojiChar;
	
	frame.size = [FEEmojiView getConstrainedToSize:titleLabel with:[self frame].size.width];
	[titleLabel setFrame:frame];
	
	[parentView addSubview:titleLabel];
}

- (CGFloat)getUIScale
{
	return [self getUISizeScale];
}

- (CGFloat)getUISizeScale
{
	static CGFloat fUIScale = 1.0f;
	
	///< 如果是iphone6 plus, 比例为1.15
//	if ([UCUIGlobal is55inchDisplay])
//	{
//		fUIScale = 1.15;
//	}
	
	return fUIScale;
}

- (CGPoint)getPointWith:(CGPoint&)pt with:(CGFloat)scale
{
	pt.x *= scale * [self getUIScale];
	pt.y *= scale * [self getUIScale];
	
	return pt;
}

+ (CGSize)getConstrainedToSize:(UILabel*)pLabel with:(NSUInteger)nMaxWidth
{
	static CGSize textSize = CGSizeZero;
	if (textSize.width == 0 || textSize.height == 0)
	{
		textSize.width = nMaxWidth;
		textSize.height = nMaxWidth;
		
		if ([pLabel.text length] > 0)
		{
			textSize = [pLabel.text sizeWithFont:pLabel.font constrainedToSize:textSize lineBreakMode:pLabel.lineBreakMode];
		}
	}
	
	return textSize;
}

- (void)onChangeFrame
{
	[self.emojiContentView setFrame:[self getContentViewFrame]];
}

#pragma mark - ==外部接口

- (void)show3DAnimation
{
	///< 目前会影响页面的刷新
	[self performSelector:@selector(delayShow3DAnimation) withObject:nil afterDelay:0.3f];
}

- (void)delayShow3DAnimation
{
	self.hidden = NO;
	
	[self executeShow3DAnimation:_emojiContentView with:kkeyShowEmojiViewTime];
}

#pragma mark - ==动画执行完成
- (void)animationDidStop:(CAAnimation *)animKeyName finished:(BOOL)flag;
{
	NSString* keyPath = nil;
	
	if ([animKeyName isKindOfClass:[CAAnimationGroup class]])
	{
		///< 自动隐藏
		[self performSelector:@selector(hiddenFestivalEmojiView) withObject:nil afterDelay:kkeyWaitTimeBeforeHidden];
	}
	
	if ([animKeyName isKindOfClass:[CAKeyframeAnimation class]])
	{
		keyPath = [(CAKeyframeAnimation*)animKeyName keyPath];
		if ([keyPath isEqualToString:kAnimationKeyHiddenView])
		{
			[self hiddenAnimationDidFinished];
		}
	}
}

- (void)hidden3DAnimation
{
	[self executeHidden3DAnimation:_emojiContentView with:kkeyHiddenEmojiViewTime];
}

///< 隐藏
- (void)hiddenFestivalEmojiView
{
	[self performSelector:@selector(hidden3DAnimation) withObject:nil afterDelay:0.0f];
}

- (void)hiddenAnimationDidFinished
{
	if (_delegate && [_delegate respondsToSelector:@selector(hiddenAnimationDidFinished)])
	{
		[_delegate hiddenAnimationDidFinished];
	}
}

#pragma mark - ==显示动画

- (void)executeShow3DAnimation:(UIView*)pView with:(NSTimeInterval)duration
{
	CAKeyframeAnimation *scaleAnimation = [self buildSizeScaleAnimation:duration];
	CAKeyframeAnimation *alphaAnimation = [self buildAlphaAnimate:duration/6];
	
	// Create an animation group to combine the keyframe and basic animations
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	// Set self as the delegate to allow for a callback to reenable user interaction
	theGroup.delegate = self;
	theGroup.duration = scaleAnimation.duration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	theGroup.animations = @[scaleAnimation, alphaAnimation];
	
	///< 插入动画
	// Add the animation group to the layer
	[pView.layer addAnimation:theGroup forKey:@"theGroupAnimation"];
}

- (CAKeyframeAnimation *)buildAlphaAnimate:(NSTimeInterval)duration
{
	// 创建关键帧动画
	CAKeyframeAnimation *alphaAnimate = [CAKeyframeAnimation animation];
	alphaAnimate.keyPath = @"opacity";
	alphaAnimate.duration = duration;
	alphaAnimate.delegate = self;
	
	///< 从 0.0f --> 1.0f(全透明-->不透明)
	alphaAnimate.values = @[
							[NSNumber numberWithFloat:0.0f],
							[NSNumber numberWithFloat:1.0f]
							];
	
	alphaAnimate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	
	alphaAnimate.keyTimes = @[@0.0, @(1.0f)];
	
	return alphaAnimate;
}

- (CAKeyframeAnimation*)buildSizeScaleAnimation:(NSTimeInterval)duration
{
	// 创建关键帧动画
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
	animation.keyPath = @"transform";
	animation.duration = duration;
	animation.delegate = self;
	
	///< 缩小到 0.8 --> 放大 1.1f --> 缩小到 0.96 --> 恢复到 1.0f
	animation.values = @[
						 [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
						 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0)],
						 [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.96f, 0.96f, 1.0)],
						 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0)]
						 ];
	
	animation.timingFunctions = @[
								  [CAMediaTimingFunction functionWithControlPoints:0.29 :0.00 :0.15 :1.00],
								  [CAMediaTimingFunction functionWithControlPoints:0.29 :0.00 :0.15 :1.00],
								  [CAMediaTimingFunction functionWithControlPoints:0.29 :0.00 :0.15 :1.00]
								  ];
	
	///< 这里是时间段的比率，第一个动画时间占总时间的比值
	animation.keyTimes = @[@(0.0), @(2.0f/6), @(4.0f/6), @(6.0f/6)];
	
	return animation;
}

#pragma mark - ==隐藏动画
- (void)executeHidden3DAnimation:(UIView*)pView with:(NSTimeInterval)duration
{
	///< 隐藏视图动画
	[pView.layer addAnimation:[self buildNothingAnimation:duration + kKeyOffsetTime] forKey:kAnimationKeyHiddenView];
	[self executeHiddenSubviews3DAnimation:duration];
}

- (void)executeHiddenSubviews3DAnimation:(NSTimeInterval)duration
{
	for (FEEmojiLabel* subLabel in [_emojiContentView subviews])
	{
		if ([subLabel isKindOfClass:[FEEmojiLabel class]])
		{
			float r = 0.1f * kKeyOffsetTime * (rand() % 10);
			[subLabel executeHiddenAnimation:duration + r];
		}
	}
}

- (CAKeyframeAnimation*)buildSizeScaleInAnimation2:(NSTimeInterval)duration
{
	// 创建关键帧动画
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
	animation.keyPath = @"transform";
	animation.duration = duration;
	animation.delegate = self;
	
	///< 1.0f --> 放大 1.2f --> 缩小到 0.2
	animation.values = @[
						 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0)],
						 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.0)],
						 [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2, 0.2, 1.0)]
						 ];
	
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	
	///< 这里是时间段的比率，第一个动画时间占总时间的比值
	animation.keyTimes = @[@(0.0), @(0.15), @(1.0)];
	
	return animation;
}

///< 没有实际的效果
- (CAKeyframeAnimation*)buildNothingAnimation:(NSTimeInterval)duration
{
	// 创建关键帧动画
	CAKeyframeAnimation *alphaAnimate = [CAKeyframeAnimation animation];
	alphaAnimate.keyPath = kAnimationKeyHiddenView;
	alphaAnimate.duration = duration;
	alphaAnimate.delegate = self;
	
	alphaAnimate.values = @[
							[NSNumber numberWithFloat:1.0f],
							[NSNumber numberWithFloat:1.0f]
							];
	
	alphaAnimate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	
	alphaAnimate.keyTimes = @[@0.0, @(1.0f)];
	
	return alphaAnimate;
}

/*
 keyTimes
 
 一个与 values 值数组对应的时间数组，定义了动画在什么时间应该到达什么值。时间以0开始，1结束。
 */

@end
