
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBTextGlyphRun.mm
 *
 * Description	: 提供获取各个CTRun参数信息的接口
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import <CoreText/CoreText.h>
#import "NBTextGlyphRun.h"


@interface NBTextGlyphRun ()

@property (nonatomic, retain) NSDictionary     *attributes;
@property (nonatomic, retain) NSArray          *stringIndices;
@property (nonatomic, assign) BOOL             shouldFreeBuffef;
@property (nonatomic, assign) NSInteger        nCount;

@end


@implementation NBTextGlyphRun

- (void)dealloc
{
	_delegate = nil;
	
	if (_run)
	{
		CFRelease(_run);
		_run = nil;
	}
	
	[self destoryBuffer];
	
	[super dealloc];
}

- (void)destoryBuffer
{
	if (_shouldFreeBuffef && _buffer)
	{
		delete [] _buffer;
		_buffer = nil;
	}
}

- (id)initWithRun:(CTRunRef)run offset:(CGFloat)offset withDelegate:(id<NBTextGlyphRunDelegate>)delegate;
{
	self = [super init];
	
	if (self)
	{
		_delegate = delegate;
		
		_run = run;
		CFRetain(_run);
		
		_offset = offset;
		//_line = layoutLine;
		
		[self calculateMetrics];
		
		[self getGlyph];
	}
	
	return self;
}

- (void)getGlyph
{
	_buffer = (CGGlyph*)CTRunGetGlyphsPtr(_run);
	
	_nCount = CTRunGetGlyphCount(_run);
	
	if (_buffer == nil)
	{
		_shouldFreeBuffef = YES;
		
		_buffer = new CGGlyph[_nCount];
		CTRunGetGlyphs(_run, CFRangeMake(0, 0), _buffer);
	}
	
	if (_buffer != nil)
	{
		memcpy(_bufGlyph, _buffer, _nCount * sizeof(CGGlyph));
	}
}

#pragma mark - Calculations
- (void)calculateMetrics
{
	// calculate metrics
	//@synchronized(self)
	{
		if (!_didCalculateMetrics)
		{
			_width = (CGFloat)CTRunGetTypographicBounds((CTRunRef)_run, CFRangeMake(0, 0), &_ascent, &_descent, &_leading);
			_didCalculateMetrics = YES;
		}
	}
}

- (CGRect)frameOfGlyphAtIndex:(NSInteger)index
{
	if (!_didCalculateMetrics)
	{
		[self calculateMetrics];
	}
	
	if (!_glyphPositionPoints)
	{
		// this is a pointer to the points inside the run, thus no retain necessary
		_glyphPositionPoints = CTRunGetPositionsPtr(_run);
	}
	
	if (!_glyphPositionPoints || index >= self.numberOfGlyphs)
	{
		return CGRectNull;
	}
	
	CGPoint glyphPosition = _glyphPositionPoints[index];
	
	CGRect rect = CGRectMake([self baselineOrigin].x + glyphPosition.x, [self baselineOrigin].y - _ascent, _offset + _width - glyphPosition.x, _ascent + _descent);
	if (index < self.numberOfGlyphs-1)
	{
		rect.size.width = _glyphPositionPoints[index+1].x - glyphPosition.x;
	}
	
	return rect;
}

// TODO: fix indices if the stringRange is modified
- (NSArray *)stringIndices
{
	if (!_stringIndices)
	{
		const CFIndex *indices = CTRunGetStringIndicesPtr(_run);
		NSInteger count = self.numberOfGlyphs;
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
		NSInteger i;
		for (i = 0; i < count; i++)
		{
			[array addObject:[NSNumber numberWithInteger:indices[i]]];
		}
		_stringIndices = array;
	}
	return _stringIndices;
}

// range of the characters from the original string
- (NSRange)stringRange
{
	if (!_stringRange.length)
	{
		CFRange range = CTRunGetStringRange(_run);
		
		_stringRange = NSMakeRange(range.location + [self stringLocationOffsetFromDelegate], range.length);
	}
	
	return _stringRange;
}

- (BOOL)isTrailingWhitespace
{
	if (_didDetermineTrailingWhitespace)
	{
		return _isTrailingWhitespace;
	}
	
	BOOL isTrailing;
	
	//if (_line.writingDirectionIsRightToLeft)
	if ([self writingDirectionIsRightToLeftFromDelegate])
	{
		isTrailing = (self == [[self glyphRuns] objectAtIndex:0]);
	}
	else
	{
		isTrailing = (self == [[self glyphRuns] lastObject]);
	}
	
	if (isTrailing)
	{
		if (!_didCalculateMetrics)
		{
			[self calculateMetrics];
		}
		
		// this is trailing whitespace if it matches the lines's trailing whitespace
		//if (_line.trailingWhitespaceWidth >= _width)
		if ([self trailingWhitespaceWidthFromDelegate])
		{
			_isTrailingWhitespace = YES;
		}
	}
	
	_didDetermineTrailingWhitespace = YES;
	return _isTrailingWhitespace;
}

#pragma mark Properites
- (NSInteger)numberOfGlyphs
{
	if (!_numberOfGlyphs)
	{
		_numberOfGlyphs = CTRunGetGlyphCount(_run);
	}
	
	return _numberOfGlyphs;
}

- (NSDictionary *)attributes
{
	if (!_attributes)
	{
		_attributes = (__bridge NSDictionary *)CTRunGetAttributes(_run);
	}
	
	return _attributes;
}

- (CGRect)frame
{
	if (!_didCalculateMetrics)
	{
		[self calculateMetrics];
	}
	
	return CGRectMake([self baselineOrigin].x + _offset, [self baselineOrigin].y - _ascent, _width, _ascent + _descent);
}

- (CGFloat)width
{
	if (!_didCalculateMetrics)
	{
		[self calculateMetrics];
	}
	
	return _width;
}

- (CGFloat)ascent
{
	if (!_didCalculateMetrics)
	{
		[self calculateMetrics];
	}
	
	return _ascent;
}

- (CGFloat)descent
{
	if (!_didCalculateMetrics)
	{
		[self calculateMetrics];
	}
	
	return _descent;
}

- (CGFloat)leading
{
	if (!_didCalculateMetrics)
	{
		[self calculateMetrics];
	}
	
	return _leading;
}

- (BOOL)writingDirectionIsRightToLeft
{
	CTRunStatus status = CTRunGetStatus(_run);
	
	return (status & kCTRunStatusRightToLeft)!=0;
}

#pragma mark - == NBTextGlyphRunDelegate

- (NSInteger)stringLocationOffsetFromDelegate
{
	NSInteger offset = 0;
	if ([_delegate respondsToSelector:@selector(stringLocationOffset)])
	{
		offset = [_delegate stringLocationOffset];
	}
	
	return offset;
}

- (BOOL)writingDirectionIsRightToLeftFromDelegate
{
	BOOL offset = 0;
	if ([_delegate respondsToSelector:@selector(writingDirectionIsRightToLeft)])
	{
		offset = [_delegate writingDirectionIsRightToLeft];
	}
	
	return offset;
}


- (CGFloat)trailingWhitespaceWidthFromDelegate
{
	CGFloat width = 0;
	if ([_delegate respondsToSelector:@selector(trailingWhitespaceWidth)])
	{
		width = [_delegate trailingWhitespaceWidth];
	}
	
	return width;
}

- (NSArray *)glyphRuns
{
	NSArray *runs = nil;
	if ([_delegate respondsToSelector:@selector(glyphRuns)])
	{
		runs = [_delegate glyphRuns];
	}
	
	return runs;
}

- (CGPoint)baselineOrigin
{
	CGPoint origin = CGPointZero;
	if ([_delegate respondsToSelector:@selector(baselineOrigin)])
	{
		origin = [_delegate baselineOrigin];
	}
	
	return origin;
}

- (void)drawRunWith:(CGContextRef)context inRect:(CGRect)rect
{
	CGPoint pt = [self baselineOrigin];
	
	CGFloat deta = 0;
	
	CGFloat fAverageHalfWidth = (NSInteger)(_width*0.5/_nCount +0.99);
	CGFloat fAverageWidth = fAverageHalfWidth + fAverageHalfWidth;
	
	CGRect glyphRect = CGRectZero;
	NSInteger nMarkCount = 0;
	CGFloat realWidth = 0;
	
	BOOL bSingleDraw = NO;
	if (bSingleDraw)
	{
		CGContextShowGlyphsAtPoint (context, pt.x, pt.y, _buffer, _nCount);
	}
	else
	{
		CGFloat markGlyphWidth[50] = {0};
		CGRect glyphRectList[50] = {0};
		
		glyphRect = CTRunGetImageBounds(_run, context, CFRangeMake(0, _nCount));
		
		int i = 0;
		for (i = 0; i < _nCount && i < 50; i++)
		{
			glyphRect = CTRunGetImageBounds(_run, context, CFRangeMake(i, 1));
			
			markGlyphWidth[i] = (NSInteger)(glyphRect.size.width + 0.999);
			
			if (markGlyphWidth[i] * 2 < fAverageWidth)
			{
				nMarkCount++;
				realWidth += fAverageHalfWidth;
			}
			realWidth += markGlyphWidth[i];
			
			glyphRectList[i] = glyphRect;
		}
		
		if (nMarkCount > 0)
		{
			deta = (rect.size.width - realWidth)/_nCount;
		}
		
		CGFloat x = 0;
		CGFloat fOffset = 0;
		
		for (i = 0; i < _nCount; i++)
		{
			x = pt.x;
			
			if (markGlyphWidth[i] < fAverageHalfWidth)
			{
				fOffset = fAverageHalfWidth * 0.5;
				x += fOffset;
			}
			
			CGContextShowGlyphsAtPoint(context, x, pt.y, _buffer + i, 1);
			
			if (markGlyphWidth[i] < fAverageHalfWidth)
			{
				fOffset = fAverageHalfWidth + markGlyphWidth[i];
			}
			else
			{
				fOffset = markGlyphWidth[i];
			}
			
			pt.x += fOffset + deta;
		}
	}
}

@end

