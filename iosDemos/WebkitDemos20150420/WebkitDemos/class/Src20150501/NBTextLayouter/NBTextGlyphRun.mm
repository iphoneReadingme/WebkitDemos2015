
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

@end


@implementation NBTextGlyphRun

- (void)dealloc
{
	_delegate = nil;
	
	if (_run)
	{
		CFRelease(_run);
	}
	
	[super dealloc];
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
	}
	
	return self;
}


#pragma mark - Calculations
- (void)calculateMetrics
{
	// calculate metrics
	@synchronized(self)
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

@end

