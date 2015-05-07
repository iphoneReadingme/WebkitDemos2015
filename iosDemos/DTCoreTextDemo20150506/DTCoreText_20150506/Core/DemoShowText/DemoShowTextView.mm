
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: DemoShowTextView.mm
 *
 * Description	: DemoShowTextView
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import "DTCoreTextLayoutFrame.h"
#import "DTCoreTextLayouter.h"
#import "DemoShowTextView.h"

@interface DemoShowTextView ()

@property(nonatomic, retain) NSAttributedString              *attributedString;
@property (nonatomic, retain) DTCoreTextLayoutFrame          *layoutFrame;
@property (nonatomic, retain)DTCoreTextLayouter              *layouter;

@end

@implementation DemoShowTextView

- (void)forTest
{
	// for test
	//	self.backgroundColor = [UIColor brownColor];
	self.layer.borderWidth = 2;
	self.layer.borderColor = [UIColor colorWithRed:0.0 green:0 blue:1.0 alpha:1.0].CGColor;
	self.layer.borderColor = [UIColor redColor].CGColor;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self forTest];
		// Initialization code.
		self.backgroundColor = [UIColor whiteColor];
		
		_attributedString = [[NSAttributedString alloc] initWithString:@"胡，你太残忍了，他还只是个孩子。"];
		
		self.layouter.attributedString = _attributedString;
	}
	return self;
}

- (void)dealloc
{
	[self releaseObject];
	
	//[super dealloc];
}

-(void)releaseObject
{
	self.attributedString = nil;
	//self.layoutConfig = nil;
	self.layoutFrame = nil;
	self.layouter = nil;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self layoutFrame];
	[self.layoutFrame drawInContext:context options:DTCoreTextLayoutFrameDrawingDefault];
	
	return;
	
	//翻转坐标系统（文本原来是倒的要翻转下）
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CTFramesetterRef framesetter = [self.layoutFrame getFramesetter];
	
	CFRange textRange = CFRangeMake(0, [_attributedString length]);
	
	CGRect columnFrame = rect;
	CGMutablePathRef framePath = CGPathCreateMutable();
	CGPathAddRect(framePath, &CGAffineTransformIdentity, columnFrame);
	CTFrameRef pageFrame = CTFramesetterCreateFrame(framesetter, textRange, framePath, NULL);
	CTFrameDraw(pageFrame, context);
	
	if (pageFrame)
	{
		CFRelease(pageFrame);
	}
	if (framePath)
	{
		CFRelease(framePath);
	}
}


- (DTCoreTextLayouter *)layouter
{
	@synchronized(self)
	{
		if (!_layouter)
		{
			if (_attributedString)
			{
				_layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:_attributedString];
				
				// allow frame caching if somebody uses the suggestedSize
				_layouter.shouldCacheLayoutFrames = YES;
			}
		}
		
		return _layouter;
	}
}

- (DTCoreTextLayoutFrame *)layoutFrame
{
	@synchronized(self)
	{
		DTCoreTextLayouter *theLayouter = self.layouter;
		
		if (!_layoutFrame)
		{
			// we can only layout if we have our own layouter
			if (theLayouter)
			{
				CGRect rect = CGRectZero;
				//UIEdgeInsetsInsetRect(self.bounds, _edgeInsets);
				rect = self.bounds;
				
				_layoutFrame = [theLayouter layoutFrameWithRect:rect range:NSMakeRange(0, 0)];
				_layoutFrame.numberOfLines = 10;
				_layoutFrame.lineBreakMode = NSLineBreakByWordWrapping;
				_layoutFrame.truncationString = nil;
				
			}
		}
		
		return _layoutFrame;
	}
}

@end

