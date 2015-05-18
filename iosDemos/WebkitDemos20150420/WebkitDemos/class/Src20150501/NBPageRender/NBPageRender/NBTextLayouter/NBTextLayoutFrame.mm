
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBTextLayoutFrame.mm
 *
 * Description	: 提供获取CTFrame参数信息的接口
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import <CoreText/CoreText.h>
#import "NBTextLine.h"
#import "NBTextLayoutFrame.h"
#import "NSString+Paragraphs.h"
#import "NBParagraphStyle.h"
#import "NBLayouterHelper.h"
#import "NBTextLayouterMacroDefine.h"


#define kNewLineChar        '\n'
#define kStepCount          300



@interface NBTextLayoutFrame ()
{
	CGRect                    _frame;
	NSRange                   _stringRange;
	CTFramesetterRef          _framesetter;
	unichar                   _curLineLastChar;
	unichar                   _nextLineSecondChar;
	unichar                   _nextLineFirstChar;
	
	NSUInteger                *_paragraphEndIndexList;
	NSInteger                 _paragraphCount;
}

@property (nonatomic, retain) NSArray                   *paragraphRanges;
@property (nonatomic, retain) NSArray                   *lines;
@property (nonatomic, assign) CGFloat                   justifyRatio;
@property(nonatomic, assign) NSLineBreakMode            lineBreakMode;
@property (nonatomic, copy) NSAttributedString          *attrString;


@end


@implementation NBTextLayoutFrame


- (void)dealloc
{
	[self releaseIndexList];
	
	[_lines release];
	_lines = nil;
	
	[_attrString release];
	_attrString = nil;
	
	[self destoryFrameSetter];
	
	[super dealloc];
}

- (void)releaseIndexList
{
	if (_paragraphEndIndexList)
	{
		delete []_paragraphEndIndexList;
		_paragraphEndIndexList = nil;
	}
}

- (void)destoryFrameSetter
{
	if (_framesetter)
	{
		CFRelease(_framesetter);
		_framesetter = nil;
	}
}

- (instancetype)initWithFrame:(CGRect)frame withAttributedString:(NSAttributedString *)attrString
{
	self = [super init];
	
	if (self)
	{
		_paragraphEndIndexList = nil;
		_paragraphCount = 0;
		
		_stringRange = NSMakeRange(0, [attrString length]);
		
		_frame = frame;
		_attrString = [attrString mutableCopy];
		[self _createFramesetter];
		
		_justifyRatio = 0.6f;
	}
	
	return self;
}

- (void)_createFramesetter
{
	if (nil == _framesetter)
	{
		///< 创建framesetter
		_framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attrString);
	}
}

- (NSUInteger)increaseParagraphListContainer:(NSInteger)curMaxCount
{
	const NSUInteger stepCount = kStepCount;
	
	NSUInteger *indexList = new NSUInteger[curMaxCount + stepCount];
	
	if (_paragraphEndIndexList)
	{
		memcpy(indexList, _paragraphEndIndexList, curMaxCount * sizeof(NSUInteger));
		
		[self releaseIndexList];
	}
	
	_paragraphEndIndexList = indexList;
	
	return curMaxCount + stepCount;
}

- (NSUInteger*)getParagraphListPtr
{
	if (nil == _paragraphEndIndexList)
	{
		NSInteger i = 0;
		NSInteger maxCount = 0;
		
		NSString *plainString = [[self attrString] string];
		NSUInteger textLength = [plainString length];
		NSRange paragraphRange = NSMakeRange(0, 0);
		NSUInteger nextParagraphBegin = 0;
		
		do
		{
			paragraphRange = [plainString rangeOfParagraphsContainingRange:NSMakeRange(nextParagraphBegin, 0) parBegIndex:NULL parEndIndex:NULL];
			if (paragraphRange.length < 1)
			{
				break;
			}
			else
			{
				if (_paragraphEndIndexList == nil)
				{
					maxCount = [self increaseParagraphListContainer:maxCount];
				}
			}
			
			if (i+1 > maxCount)
			{
				maxCount = [self increaseParagraphListContainer:maxCount];
			}
			
			nextParagraphBegin = NSMaxRange(paragraphRange);
			*(_paragraphEndIndexList + i) = nextParagraphBegin;
			i++;
			
			if (nextParagraphBegin >= textLength)
			{
				break;
			}
			
		}while (true);
		
		_paragraphCount = i;
	}
	
	return _paragraphEndIndexList;
}

- (NSArray *)paragraphRanges
{
	if (!_paragraphRanges)
	{
		NSString *plainString = [[self attrString] string];
		NSUInteger length = [plainString length];
		
		NSRange paragraphRange = [plainString rangeOfParagraphsContainingRange:NSMakeRange(0, 0) parBegIndex:NULL parEndIndex:NULL];
		
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		while (paragraphRange.length)
		{
			NSValue *value = [NSValue valueWithRange:paragraphRange];
			[tmpArray addObject:value];
			
			NSUInteger nextParagraphBegin = NSMaxRange(paragraphRange);
			
			if (nextParagraphBegin>=length)
			{
				break;
			}
			
			paragraphRange = [plainString rangeOfParagraphsContainingRange:NSMakeRange(nextParagraphBegin, 0) parBegIndex:NULL parEndIndex:NULL];
		}
		
		_paragraphRanges = [tmpArray retain];
	}
	
	return _paragraphRanges;
}

- (BOOL)isLineFirstInParagraph:(NBTextLine *)line
{
	NSRange lineRange = line.stringRange;
	
	if (lineRange.location == 0)
	{
		return YES;
	}
	
	NSInteger prevLineLastUnicharIndex = lineRange.location - 1;
	unichar prevLineLastUnichar = [[_attrString string] characterAtIndex:prevLineLastUnicharIndex];
	
	return [[NSCharacterSet newlineCharacterSet] characterIsMember:prevLineLastUnichar];
}

- (BOOL)isLineLastInParagraph:(NBTextLine *)line
{
	BOOL bRet = NO;
	
	if (line.stringRange.length > 1)
	{
		unichar charCheck = [[_attrString string] characterAtIndex:line.stringRange.length - 1];
		bRet = (charCheck == kNewLineChar);
	}
	
	return bRet;
}

- (CGPoint)_algorithmLegacy_BaselineOriginToPositionLine:(NBTextLine *)line afterLine:(NBTextLine *)previousLine
{
	CGPoint lineOrigin = previousLine.baselineOrigin;
	
	NSInteger lineStartIndex = line.stringRange.location;
	
	CTParagraphStyleRef lineParagraphStyle = (__bridge CTParagraphStyleRef)[_attrString
																			attribute:(id)kCTParagraphStyleAttributeName
																			atIndex:lineStartIndex effectiveRange:NULL];
	CGFloat usedLeading = line.leading;
	
	if (usedLeading == 0.0f)
	{
		CGFloat tmpHeight = line.ascent + line.descent;
		usedLeading = ceil(0.2f * tmpHeight);
		
		if (usedLeading>20)
		{
			usedLeading = 0;
		}
	}
	else
	{
		usedLeading = ceil(MAX((line.ascent + line.descent)*0.1f, usedLeading));
	}
	
	if (previousLine == nil)
	{
		lineOrigin.y = -line.descent;
		return lineOrigin;
	}
	
	CGFloat lineHeight = 0;
	CGFloat minLineHeight = 0;
	CGFloat maxLineHeight = 0;
	BOOL usesForcedLineHeight = NO;
	
	if (CTParagraphStyleGetValueForSpecifier(lineParagraphStyle, kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(minLineHeight), &minLineHeight))
	{
		usesForcedLineHeight = YES;
		
		if (lineHeight<minLineHeight)
		{
			lineHeight = minLineHeight;
		}
	}
	
	if (lineHeight==0)
	{
		lineHeight = line.descent + line.ascent + usedLeading;
	}
	
	if ([self isLineLastInParagraph:previousLine])
	{
		CTParagraphStyleRef previousLineParagraphStyle = (__bridge CTParagraphStyleRef)[_attrString
																						attribute:(id)kCTParagraphStyleAttributeName
																						atIndex:previousLine.stringRange.location effectiveRange:NULL];
		
		CGFloat paraSpacing;
		
		if (CTParagraphStyleGetValueForSpecifier(previousLineParagraphStyle, kCTParagraphStyleSpecifierParagraphSpacing, sizeof(paraSpacing), &paraSpacing))
		{
			lineOrigin.y += paraSpacing;
		}
		
		CGFloat paraSpacingBefore;
		
		if (CTParagraphStyleGetValueForSpecifier(lineParagraphStyle, kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(paraSpacingBefore), &paraSpacingBefore))
		{
			lineOrigin.y += paraSpacingBefore;
		}
	}
	
	CGFloat lineSpacing = 0;
	if (CTParagraphStyleGetValueForSpecifier(lineParagraphStyle, kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(lineSpacing), &lineSpacing))
	{
		lineOrigin.y += lineSpacing;
	}
	
	CTLineBreakMode lineBreakModr;
	if (CTParagraphStyleGetValueForSpecifier(lineParagraphStyle, kCTParagraphStyleSpecifierLineBreakMode, sizeof(lineBreakModr), &lineBreakModr))
	{
		lineBreakModr = lineBreakModr;
	}
	
	CGFloat lineHeightMultiplier = 0;
	
	if (CTParagraphStyleGetValueForSpecifier(lineParagraphStyle, kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(lineHeightMultiplier), &lineHeightMultiplier))
	{
		if (lineHeightMultiplier>0.0f)
		{
			lineHeight *= lineHeightMultiplier;
		}
	}
	
	if (CTParagraphStyleGetValueForSpecifier(lineParagraphStyle, kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maxLineHeight), &maxLineHeight))
	{
		if (maxLineHeight>0 && lineHeight>maxLineHeight)
		{
			lineHeight = maxLineHeight;
		}
	}
	
	lineOrigin.y += lineHeight;
	
	lineOrigin.x = line.baselineOrigin.x;
	
	if (!usesForcedLineHeight)
	{
		CGFloat previousLineBottom = CGRectGetMaxY(previousLine.frame);
		
		if (lineOrigin.y - line.ascent < previousLineBottom)
		{
			lineOrigin.y = previousLineBottom + line.ascent;
		}
	}
	
	lineOrigin.y = ceil(lineOrigin.y);
	
	return lineOrigin;
}

#pragma mark - Calculations

- (NSRange)visibleStringRange
{
	return _stringRange;
}

- (NSArray *)getLines
{
	return _lines;
}

- (NSInteger)getCharOffsetWithRange:(NSRange)lineRange
{
	NSInteger nOffset = 0;
	do
	{
		if (lineRange.length < 5)
		{
			break;
		}
		
		NSInteger lineEnd = NSMaxRange(lineRange);
		NSUInteger maxCharsCount = NSMaxRange(_stringRange);
		
		_curLineLastChar = [[_attrString string] characterAtIndex:lineEnd - 1];
		
		if (_curLineLastChar == kNewLineChar)
		{
			break;
		}
		
		if ([NBLayouterHelper isPrePartOfPairMarkChar:_curLineLastChar])
		{
			nOffset = -1;
			break;
		}
		
		NSInteger nCheckCharsCount = 0;
		if (lineEnd + 2 <= maxCharsCount)
		{
			nCheckCharsCount = 2;
			_nextLineFirstChar = [[_attrString string] characterAtIndex:lineEnd];
			_nextLineSecondChar = [[_attrString string] characterAtIndex:lineEnd + 1];
		}
		else if (lineEnd + 1 <= maxCharsCount)
		{
			nCheckCharsCount = 1;
			_nextLineFirstChar = [[_attrString string] characterAtIndex:lineEnd];
		}
		
		nOffset = [NBLayouterHelper getSpecialMarkCharCount:_nextLineFirstChar with:_nextLineSecondChar];
		
#ifdef ENABLE_NBLayoutFrame_Debug
		unichar ch = 0;
		if ([lineString length] > 2)
		{
			ch = [lineString characterAtIndex:[lineString length] - 2];
		}
		NSString* lastChar = nil;
		if ([lineString length] > 1)
		{
			lastChar = [[[_attrString string] substringWithRange:lineRange] substringFromIndex:[lineString length] - 1];
		}
		NSLog(@"lineString=[L:%d][c:%d][ch:%d,%c,%@][%@]", [typesetLines count], [lineString length], ch, ch, lastChar, lineString);
#endif
	}while (0);
	
	return nOffset;
}

- (BOOL)createFrameInRect:(CGRect)frame withRange:(NSRange)textRange
{
	BOOL bRet = NO;
	
	if ([_attrString length] <= textRange.location)
	{
		return bRet;
	}
	
	NSUInteger length = [_attrString length];
	if (textRange.length == 0)
	{
		length = length - textRange.location;
	}
	else
	{
		if (textRange.location + textRange.length < length)
		{
			length = textRange.length;
		}
		else
		{
			length = length - textRange.location;
		}
	}
	
	if (length < 1)
	{
		_stringRange = NSMakeRange(0, 0);
		return bRet;
	}
	
	_stringRange = NSMakeRange(textRange.location, length);
	
	_frame = frame;
	
	CTTypesetterRef typesetter = CTFramesetterGetTypesetter(_framesetter);
	
	NSMutableArray *typesetLines = [NSMutableArray array];
	
	NBTextLine *previousLine = nil;
	
	NSRange lineRange = _stringRange;
	
	[self getParagraphListPtr];
	NSUInteger curParagraphEnd = 0;
	
	CGFloat maxY = _frame.size.height;
	NSUInteger maxIndex = NSMaxRange(_stringRange);
	NSUInteger fittingLength = 0;
	
	NBTextLine *firstLine = nil;
	BOOL bHasCheckMarkChar = NO;
	
	do
	{
		_curLineLastChar = 0;
		_nextLineSecondChar = 0;
		_nextLineFirstChar = 0;
		
		if ([typesetLines count] > 15)
		{
			int n = 0;
			n = 0;
		}
		BOOL bEnd = NO;
		
		NSInteger i = 0;
		
		while (lineRange.location >= curParagraphEnd)
		{
			if (i < _paragraphCount)
			{
				curParagraphEnd = *(_paragraphEndIndexList + i);
				
				i++;
			}
			else
			{
				bEnd = YES;
				break;
			}
		}
		
		if (bEnd)
		{
			break;
		}
		
		BOOL isAtBeginOfParagraph = (curParagraphEnd == lineRange.location + lineRange.length);
		
		CGFloat headIndent = 0;
		CGFloat tailIndent = 0;
		
		CTParagraphStyleRef paragraphStyle = (__bridge CTParagraphStyleRef)[_attrString attribute:(id)kCTParagraphStyleAttributeName atIndex:lineRange.location effectiveRange:NULL];
		
		if (isAtBeginOfParagraph)
		{
			CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(headIndent), &headIndent);
		}
		else
		{
			CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierHeadIndent, sizeof(headIndent), &headIndent);
		}
		
		CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierTailIndent, sizeof(tailIndent), &tailIndent);
		
		CGFloat lineOriginX = 0;
		CGFloat availableWidth = 0;
		
		CGFloat totalLeftPadding = 0;
		CGFloat totalRightPadding = 0;
		
		if (tailIndent<=0)
		{
			availableWidth = _frame.size.width - headIndent - totalRightPadding + tailIndent - totalLeftPadding;
		}
		else
		{
			availableWidth = tailIndent - headIndent - totalLeftPadding - totalRightPadding;
		}
		
		CGFloat offset = totalLeftPadding;
		
		if ([[_attrString string] characterAtIndex:lineRange.location] != '\t')
		{
			offset += headIndent;
		}
		
		lineRange.length = CTTypesetterSuggestClusterBreak(typesetter, lineRange.location, availableWidth);
		if (bHasCheckMarkChar && lineRange.length == 1)
		{
			bHasCheckMarkChar = NO;
			
			if ([[_attrString string] characterAtIndex:lineRange.location] == kNewLineChar)
			{
				fittingLength += lineRange.length;
				lineRange.location += lineRange.length;
				continue;
			}
		}
		
		NSInteger nCount = 0;
		
		if (NSMaxRange(lineRange) > maxIndex)
		{
			lineRange.length = maxIndex - lineRange.location;
		}
		else
		{
			nCount = [self getCharOffsetWithRange:lineRange];
		}
		
		bHasCheckMarkChar = nCount > 0;
		if (nCount != 0)
		{
			lineRange.length += nCount;
		}
		
		CTLineRef line;
		
		line = CTTypesetterCreateLine(typesetter, CFRangeMake(lineRange.location, lineRange.length));
		
		CGFloat currentLineWidth = (CGFloat)CTLineGetTypographicBounds(line, NULL, NULL, NULL);
		CTTextAlignment textAlignment = kCTTextAlignmentLeft;
		
		if (!CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment))
		{
			textAlignment = kCTNaturalTextAlignment;
		}
		BOOL isRTL = NO;
		CTWritingDirection baseWritingDirection;
		
		if (CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(baseWritingDirection), &baseWritingDirection))
		{
			isRTL = (baseWritingDirection == kCTWritingDirectionRightToLeft);
		}
		else
		{
			baseWritingDirection = kCTWritingDirectionNatural;
		}
		
		NSUInteger nCharWidth = currentLineWidth/lineRange.length;
		CGFloat deta = (_frame.size.width - currentLineWidth);
		if (nCount && ((0.8*_frame.size.width < currentLineWidth && nCharWidth < deta) || currentLineWidth > _frame.size.width))
		{
			textAlignment = kCTJustifiedTextAlignment;
		}
		
		NSAttributedString *attribStr = nil;
		switch (textAlignment)
		{
			case kCTLeftTextAlignment:
			{
				lineOriginX = _frame.origin.x + offset;
				break;
			}
			case kCTJustifiedTextAlignment:
			{
				NSString *lineString = [[_attrString string] substringWithRange:lineRange];
				
				NSRange range;
				NSDictionary * attributes = [_attrString attributesAtIndex:lineRange.location effectiveRange:&range];
				
				attribStr = [[NSAttributedString alloc] initWithString:lineString attributes:attributes];
				
				CTLineRef newLineRef = CTLineCreateWithAttributedString((__bridge  CFAttributedStringRef)(attribStr));
				
				CTLineRef justifiedLine = nil;
				if (newLineRef)
				{
					justifiedLine = CTLineCreateJustifiedLine(newLineRef, 1.0f, availableWidth);
					CFRelease(newLineRef);
				}
				
				if (justifiedLine)
				{
					CFRelease(line);
					line = justifiedLine;
				}
				currentLineWidth = (CGFloat)CTLineGetTypographicBounds(line, NULL, NULL, NULL);
				
				if (isRTL)
				{
					lineOriginX = _frame.origin.x + offset + (CGFloat)CTLineGetPenOffsetForFlush(line, 1.0, availableWidth);
				}
				else
				{
					lineOriginX = _frame.origin.x + offset;
				}
				
				break;
			}
			default:
			{
				break;
			}
		}
		if (!line)
		{
			continue;
		}
		
		NBTextLine *newLine = [[NBTextLine alloc] initWithLine:line stringLocationOffset: 0];
		newLine.text = [[_attrString string] substringWithRange:lineRange];
		
		newLine.writingDirectionIsRightToLeft = isRTL;
		CFRelease(line);
		
		CGPoint newLineBaselineOrigin = [self _algorithmLegacy_BaselineOriginToPositionLine:newLine afterLine:previousLine];
		newLineBaselineOrigin.x = lineOriginX;
		newLine.baselineOrigin = newLineBaselineOrigin;
		
		CGFloat lineBottom = CGRectGetMaxY(newLine.frame);
		
		if (firstLine != nil)
		{
			lineBottom = newLine.frame.origin.y - firstLine.frame.origin.y + firstLine.lineHeight;
		}
		else
		{
			lineBottom = newLine.lineHeight;
		}
		
		if (lineBottom > maxY)
		{
			[newLine release];
			newLine = nil;
			if ([typesetLines count])
			{
				bRet = YES;
				break;
			}
			else
			{
				break;
			}
		}
		
		[typesetLines addObject:newLine];
		if (firstLine == nil)
		{
			firstLine = newLine;
		}
		
		fittingLength += lineRange.length;
		
		lineRange.location += lineRange.length;
		previousLine = newLine;
		
		[newLine release];
		newLine = nil;
		
	}while (lineRange.location < maxIndex);
	
	_lines = [typesetLines retain];
	
	if (![_lines count])
	{
		_stringRange = NSMakeRange(0, 0);
		
		return bRet;
	}
	
	bRet = YES;
	
	_stringRange.location = _stringRange.location;
	_stringRange.length = fittingLength;
	
	return bRet;
}

- (void)updateLinesOriginInRect:(CGRect)frame
{
//	NSInteger i = 0;
//	NSInteger nCount = 0;
	
	NSArray *lineList = _lines;
	for (NBTextLine* lineObj in lineList)
	{
//		if (nCount < i + 2)
//		{
//			i = i;
//		}
//		i++;
		
		CGPoint origin = lineObj.baselineOrigin;
		CGFloat h = lineObj.descent + lineObj.ascent + lineObj.leading;
		
		origin.y = frame.origin.y + frame.size.height - origin.y - h;
		lineObj.baselineOrigin = origin;
	}
}

- (NSString*)getLineText
{
	return nil;
}

- (void)drawLinesWith:(CGContextRef)context inRect:(CGRect)rect
{
	[self updateLinesOriginInRect:rect];;
	
//	NSInteger nCount = 0;
//	NSInteger i = 1;
	NSArray *lineList = _lines;
	for (NBTextLine* lineObj in lineList)
	{
//		if (nCount < i + 2)
//		{
//			i = i;
//		}
//		i++;
		
		[lineObj drawLinesWith:context inRect:rect];
	}
}

@end

