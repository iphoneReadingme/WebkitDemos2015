
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBTextLine.mm
 *
 * Description	: 提供获取各个CTLine参数信息的接口
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import <CoreText/CoreText.h>
#import "NSDictionary+NBCoreText.h"
#import "NBTextGlyphRun.h"
#import "NBTextLine.h"
#import "NBConstants.h"
#import "NBTextLayouterMacroDefine.h"


@interface NBTextLine ()<NBTextGlyphRunDelegate>

@property (nonatomic, retain) NSArray *glyphRuns;
@property (nonatomic, assign) NSInteger stringLocationOffset;
@property (nonatomic, assign) BOOL didCalculateMetrics;
@property (nonatomic, assign) CGFloat trailingWhitespaceWidth;
@property (nonatomic, assign) BOOL hasScannedGlyphRunsForValues;

@end


@implementation NBTextLine

- (void)dealloc
{
	[self destoryGlyphRuns];
	
	[_text release];
	_text = nil;
	
	if (_line)
	{
		CFRelease(_line);
		_line = nil;
	}
	
	[super dealloc];
}

- (void)destoryGlyphRuns
{
	if (_glyphRuns)
	{
		for (NBTextGlyphRun* nbRun in _glyphRuns)
		{
			nbRun.delegate = nil;
		}
		
		[_glyphRuns release];
		_glyphRuns = nil;
	}
}

- (id)initWithLine:(CTLineRef)line stringLocationOffset:(NSInteger)stringLocationOffset
{
	if (!line)
	{
		return nil;
	}
	
	if ((self = [super init]))
	{
		_line = line;
		CFRetain(_line);
		
		_needsToDetectWritingDirection = YES;
		
		_stringLocationOffset = stringLocationOffset;
		
		[self _calculateMetrics];
	}
	return self;
}

- (NSInteger)numberOfGlyphs
{
	NSInteger ret = 0;
	for (NBTextGlyphRun *oneRun in self.glyphRuns)
	{
		ret += [oneRun numberOfGlyphs];
	}
	
	return ret;
}

- (CGFloat)offsetForStringIndex:(NSInteger)index
{
	index -= _stringLocationOffset;
	
	return CTLineGetOffsetForStringIndex(_line, index, NULL);
}

- (NSInteger)stringIndexForPosition:(CGPoint)position
{
	CGPoint adjustedPosition = position;
	CGRect frame = self.frame;
	adjustedPosition.x -= frame.origin.x;
	adjustedPosition.y -= frame.origin.y;
	
	NSInteger index = CTLineGetStringIndexForPosition(_line, adjustedPosition);
	
	index += _stringLocationOffset;
	
	return index;
}

- (void)_calculateMetrics
{
	if (!_didCalculateMetrics)
	{
		_width = (CGFloat)CTLineGetTypographicBounds(_line, &_ascent, &_descent, &_leading);
		_trailingWhitespaceWidth = (CGFloat)CTLineGetTrailingWhitespaceWidth(_line);
		
		_didCalculateMetrics = YES;
	}
}

- (BOOL)isHorizontalRule
{
	if (self.textRange.length>1)
	{
		return NO;
	}
	
	NSArray *runs = self.glyphRuns;
	
	if ([runs count]>1)
	{
		return NO;
	}
	
	NBTextGlyphRun *singleRun = [runs lastObject];
	
	if ([singleRun.attributes objectForKey:NBHorizontalRuleStyleAttribute])
	{
		return YES;
	}
	
	return NO;
}

- (void)_scanGlyphRunsForValues
{
	@synchronized(self)
	{
		CGFloat maxOffset = 0;
		CGFloat maxFontSize = 0;
		
		for (NBTextGlyphRun *oneRun in self.glyphRuns)
		{
			CTFontRef usedFont = (__bridge CTFontRef)([oneRun.attributes objectForKey:(id)kCTFontAttributeName]);
			
			if (usedFont)
			{
				maxOffset = MAX(maxOffset, fabs(CTFontGetUnderlinePosition(usedFont)));
				
				maxFontSize = MAX(maxFontSize, CTFontGetSize(usedFont));
			}
		}
		
		_underlineOffset = maxOffset;
		_lineHeight = maxFontSize;
		
		_hasScannedGlyphRunsForValues= YES;
	}
}


#pragma mark - Properties

- (NSArray *)getGlyphRuns
{
	return self.glyphRuns;
}

- (NSArray *)glyphRuns
{
	@synchronized(self)
	{
		if (!_glyphRuns)
		{
			CFArrayRef runs = CTLineGetGlyphRuns(_line);
			CFIndex runCount = CFArrayGetCount(runs);
			
			if (runCount)
			{
				NSMutableArray *tmpArray = [[[NSMutableArray alloc] initWithCapacity:runCount] autorelease];
				
				for (CFIndex i=0; i<runCount; i++)
				{
					CTRunRef oneRun = (CTRunRef)CFArrayGetValueAtIndex(runs, i);
					
					CGPoint *positions = (CGPoint*)CTRunGetPositionsPtr(oneRun);
					
					BOOL shouldFreePositions = NO;
					
					if (positions == NULL)
					{
						CFIndex glyphCount = CTRunGetGlyphCount(oneRun);
						
						shouldFreePositions = YES;
						
						size_t positionsBufferSize = sizeof(CGPoint) * glyphCount;
						CGPoint *positionsBuffer = (CGPoint*)malloc(positionsBufferSize);
						CTRunGetPositions(oneRun, CFRangeMake(0, 0), positionsBuffer);
						positions = positionsBuffer;
					}
					
					CGPoint position = positions[0];
					
					NBTextGlyphRun *glyphRun = [[[NBTextGlyphRun alloc] initWithRun:oneRun offset:position.x withDelegate:self] autorelease];
					[tmpArray addObject:glyphRun];
					
					if ( shouldFreePositions )
					{
						free(positions);
					}
				}
				
				_glyphRuns = [tmpArray retain];
			}
		}
		
		return _glyphRuns;
	}
}

- (CGRect)frame
{
	if (!_didCalculateMetrics)
	{
		[self _calculateMetrics];
	}
	
	CGRect frame = CGRectMake(_baselineOrigin.x, _baselineOrigin.y - _ascent, _width, _ascent + _descent);
	
	if ([self isHorizontalRule])
	{
		frame.size.width = CGFLOAT_MAX;
	}
	
	return frame;
}

- (CGFloat)width
{
	if (!_didCalculateMetrics)
	{
		[self _calculateMetrics];
	}
	
	return _width;
}

- (CGFloat)ascent
{
	if (!_didCalculateMetrics)
	{
		[self _calculateMetrics];
	}
	
	return _ascent;
}

- (void)setAscent:(CGFloat)ascent
{
	if (!_didCalculateMetrics)
	{
		[self _calculateMetrics];
	}
	
	_ascent = ascent;
}

- (CGFloat)descent
{
	if (!_didCalculateMetrics)
	{
		[self _calculateMetrics];
	}
	
	return _descent;
}

- (CGFloat)leading
{
	if (!_didCalculateMetrics)
	{
		[self _calculateMetrics];
	}
	
	return _leading;
}

- (CGFloat)underlineOffset
{
	if (!_hasScannedGlyphRunsForValues)
	{
		[self _scanGlyphRunsForValues];
	}
	
	return _underlineOffset;
}

- (CGFloat)lineHeight
{
	if (!_hasScannedGlyphRunsForValues)
	{
		[self _scanGlyphRunsForValues];
	}
	
	return _lineHeight;
}

- (NBParagraphStyle *)paragraphStyle
{
	NBTextGlyphRun *lastRun = [self.glyphRuns lastObject];
	NSDictionary *attributes = lastRun.attributes;
	
	return [attributes paragraphStyle];
}

- (CGFloat)trailingWhitespaceWidth
{
	if (!_didCalculateMetrics)
	{
		[self _calculateMetrics];
	}
	
	return _trailingWhitespaceWidth;
}

- (BOOL)writingDirectionIsRightToLeft
{
	if (_needsToDetectWritingDirection)
	{
		if ([self.glyphRuns count])
		{
			NBTextGlyphRun *firstRun = [self.glyphRuns objectAtIndex:0];
			
			_writingDirectionIsRightToLeft = [firstRun writingDirectionIsRightToLeft];
		}
	}
	
	return _writingDirectionIsRightToLeft;
}

- (void)setWritingDirectionIsRightToLeft:(BOOL)writingDirectionIsRightToLeft
{
	_writingDirectionIsRightToLeft = writingDirectionIsRightToLeft;
	_needsToDetectWritingDirection = NO;
}


#pragma mark - Calculations
- (NSArray *)stringIndices
{
	NSMutableArray *array = [NSMutableArray array];
	for (NBTextGlyphRun *oneRun in self.glyphRuns)
	{
		[array addObjectsFromArray:[oneRun stringIndices]];
	}
	return array;
}

- (CGRect)frameOfGlyphAtIndex:(NSInteger)index
{
	for (NBTextGlyphRun *oneRun in self.glyphRuns)
	{
		NSInteger count = [oneRun numberOfGlyphs];
		if (index >= count)
		{
			index -= count;
		}
		else
		{
			return [oneRun frameOfGlyphAtIndex:index];
		}
	}
	
	return CGRectZero;
}

- (NSArray *)glyphRunsWithRange:(NSRange)range
{
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self numberOfGlyphs]];
	
	for (NBTextGlyphRun *oneRun in self.glyphRuns)
	{
		NSRange runRange = [oneRun stringRange];
		
		NSRange intersectionRange = NSIntersectionRange(range, runRange);
		
		if (intersectionRange.length)
		{
			[tmpArray addObject:oneRun];
		}
	}
	
	return tmpArray;
}

- (CGRect)frameOfGlyphsWithRange:(NSRange)range
{
	NSArray *glyphRuns = [self glyphRunsWithRange:range];
	
	CGRect tmpRect = CGRectMake(CGFLOAT_MAX, CGFLOAT_MAX, 0, 0);
	
	for (NBTextGlyphRun *oneRun in glyphRuns)
	{
		CGRect glyphFrame = oneRun.frame;
		
		if (glyphFrame.origin.x < tmpRect.origin.x)
		{
			tmpRect.origin.x = glyphFrame.origin.x;
		}
		
		if (glyphFrame.origin.y < tmpRect.origin.y)
		{
			tmpRect.origin.y = glyphFrame.origin.y;
		}
		
		if (glyphFrame.size.height > tmpRect.size.height)
		{
			tmpRect.size.height = glyphFrame.size.height;
		}
		
		tmpRect.size.width = glyphFrame.origin.x + glyphFrame.size.width - tmpRect.origin.x;
	}
	
	CGFloat maxX = CGRectGetMaxX(self.frame) - _trailingWhitespaceWidth;
	if (CGRectGetMaxX(tmpRect) > maxX)
	{
		tmpRect.size.width = maxX - tmpRect.origin.x;
	}
	
	return tmpRect;
}

- (NSString*)getLineText
{
	return nil;
}

- (void)drawLinesWith:(CGContextRef)context inRect:(CGRect)rect
{
	CGPoint linePtOrigin = _baselineOrigin;
	
	CGContextSetTextPosition(context, linePtOrigin.x, linePtOrigin.y);
	CTLineDraw(_line, context);
}

@end


