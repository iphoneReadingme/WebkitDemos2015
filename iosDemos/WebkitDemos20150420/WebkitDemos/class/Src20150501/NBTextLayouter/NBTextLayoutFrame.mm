
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
#import "NBTextLayouterMacroDefine.h"

@interface NBTextLayoutFrame ()
{
	NSRange                   _stringRange;
	CTFrameRef                _textFrame;
	
	NSInteger                 _numberLinesFitInFrame;
	CTFramesetterRef          _framesetter;
}


@property (nonatomic, retain) NSArray                   *lines;
@property (nonatomic, assign) CGFloat                   additionalPaddingAtBottom;
@property (nonatomic, assign) CGFloat                   justifyRatio;
@property(nonatomic, assign) NSLineBreakMode            lineBreakMode;
@property(nonatomic, copy) NSAttributedString           *truncationString;
@property (nonatomic, copy) NSAttributedString          *attrString;


@end


@implementation NBTextLayoutFrame


- (void)dealloc
{
	[_attrString release];
	_attrString = nil;
	
	[self destoryFrameSetter];
	
	[super dealloc];
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
		// determine correct target range
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

#pragma mark - Building the Lines

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
	if( _numberOfLines != numberOfLines )
	{
		_numberOfLines = numberOfLines;
		// clear lines cache
		_lines = nil;
	}
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
	if( _lineBreakMode != lineBreakMode )
	{
		_lineBreakMode = lineBreakMode;
		// clear lines cache
		_lines = nil;
	}
}

- (CTLineTruncationType)lineTruncationTypeFromNSLineBreakMode:(NSLineBreakMode)lineBreakMode
{
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
	switch (lineBreakMode)
	{
		case UILineBreakModeHeadTruncation:
			return kCTLineTruncationStart;
			
		case UILineBreakModeMiddleTruncation:
			return kCTLineTruncationMiddle;
			
		default:
			return kCTLineTruncationEnd;
	}
#else
	switch (lineBreakMode)
	{
		case NSLineBreakByTruncatingHead:
			return kCTLineTruncationStart;
			
		case NSLineBreakByTruncatingMiddle:
			return kCTLineTruncationMiddle;
			
		default:
			return kCTLineTruncationEnd;
	}
#endif
}

- (void)setTruncationString:(NSAttributedString *)truncationString
{
	if( ![_truncationString isEqualToAttributedString:truncationString] )
	{
		_truncationString = truncationString;
		
		if( self.numberOfLines > 0 )
		{
			// clear lines cache
			_lines = nil;
		}
	}
}

- (NSArray *)linesVisibleInRect:(CGRect)rect
{
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[[self getLines] count]];
	
	CGFloat minY = CGRectGetMinY(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
	
	for (NBTextLine *oneLine in self.lines)
	{
		CGRect lineFrame = oneLine.frame;
		
		// lines before the rect
		if (CGRectGetMaxY(lineFrame)<minY)
		{
			// skip
			continue;
		}
		
		// line is after the rect
		if (lineFrame.origin.y > maxY)
		{
			break;
		}
		
		// CGRectIntersectsRect returns false if the frame has 0 width, which
		// lines that consist only of line-breaks have. Set the min-width
		// to one to work-around.
		lineFrame.size.width = lineFrame.size.width>1?lineFrame.size.width:1;
		
		if (CGRectIntersectsRect(rect, lineFrame))
		{
			[tmpArray addObject:oneLine];
		}
	}
	
	return tmpArray;
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
			
			// next paragraph
			paragraphRange = [plainString rangeOfParagraphsContainingRange:NSMakeRange(nextParagraphBegin, 0) parBegIndex:NULL parEndIndex:NULL];
		}
		
		_paragraphRanges = tmpArray; // no copy for performance
	}
	
	return _paragraphRanges;
}

- (void)setJustifyRatio:(CGFloat)justifyRatio
{
	if (_justifyRatio != justifyRatio)
	{
		_justifyRatio = justifyRatio;
		
		// clear lines cache
		_lines = nil;
	}
	
}
// returns YES if the given line is the first in a paragraph
- (BOOL)isLineFirstInParagraph:(NBTextLine *)line
{
	NSRange lineRange = line.stringRange;
	
	if (lineRange.location == 0)
	{
		return YES;
	}
	
	NSInteger prevLineLastUnicharIndex =lineRange.location - 1;
	unichar prevLineLastUnichar = [[_attrString string] characterAtIndex:prevLineLastUnicharIndex];
	
	return [[NSCharacterSet newlineCharacterSet] characterIsMember:prevLineLastUnichar];
}

// returns YES if the given line is the last in a paragraph
- (BOOL)isLineLastInParagraph:(NBTextLine *)line
{
	NSString *lineString = [[_attrString string] substringWithRange:line.stringRange];
	
	if ([lineString hasSuffix:@"\n"])
	{
		return YES;
	}
	
	return NO;
}

// determins the "half leading"
- (CGFloat)_algorithmWebKit_halfLeadingOfLine:(NBTextLine *)line
{
	CGFloat maxFontSize = [line lineHeight];
	
	NBParagraphStyle *paragraphStyle = [line paragraphStyle];
	
	if (paragraphStyle.minimumLineHeight && paragraphStyle.minimumLineHeight > maxFontSize)
	{
		maxFontSize = paragraphStyle.minimumLineHeight;
	}
	
	if (paragraphStyle.maximumLineHeight && paragraphStyle.maximumLineHeight < maxFontSize)
	{
		maxFontSize = paragraphStyle.maximumLineHeight;
	}
	
	CGFloat leading;
	
	if (paragraphStyle.lineHeightMultiple > 0)
	{
		leading = maxFontSize * paragraphStyle.lineHeightMultiple;
	}
	else
	{
		// reasonable "normal"
		leading = maxFontSize * 1.1f;
	}
	
	// subtract inline box height
	CGFloat inlineBoxHeight = line.ascent + line.descent;
	return (leading - inlineBoxHeight)/2.0f;
	
//	return 0;
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
		// font has no leading, so we fake one (e.g. Helvetica)
		CGFloat tmpHeight = line.ascent + line.descent;
		usedLeading = ceil(0.2f * tmpHeight);
		
		if (usedLeading>20)
		{
			// we have a large image increasing the ascender too much for this calc to work
			usedLeading = 0;
		}
	}
	else
	{
		// make sure that we don't have less than 10% of line height as leading
		usedLeading = ceil(MAX((line.ascent + line.descent)*0.1f, usedLeading));
	}
	
	//Meet the first line in this frame
	if (!previousLine)
	{
		// The first line may or may not be the start of paragraph. It depends on the the range passing to
		// - (DTCoreTextLayoutFrame *)layoutFrameWithRect:(CGRect)frame range:(NSRange)range;
		// So Check it in a safe way:
		if ([self isLineFirstInParagraph:line])
		{
			
			CGFloat paraSpacingBefore = 0;
			
			if (CTParagraphStyleGetValueForSpecifier(lineParagraphStyle, kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(paraSpacingBefore), &paraSpacingBefore))
			{
				lineOrigin.y += paraSpacingBefore;
			}
			
			// preserve own baseline x
			lineOrigin.x = line.baselineOrigin.x;
			
			// origins are rounded
			lineOrigin.y = ceil(lineOrigin.y);// + usedLeading;
			
			return lineOrigin;
			
		}
		
	}
	
	// get line height in px if it is specified for this line
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
	
	// is absolute line height set?
	if (lineHeight==0)
	{
		lineHeight = line.descent + line.ascent + usedLeading;
	}
	
	if ([self isLineLastInParagraph:previousLine])
	{
		// need to get paragraph spacing
		CTParagraphStyleRef previousLineParagraphStyle = (__bridge CTParagraphStyleRef)[_attrString
																						attribute:(id)kCTParagraphStyleAttributeName
																						atIndex:previousLine.stringRange.location effectiveRange:NULL];
		
		// Paragraph spacings are paragraph styles and should not be multiplied by kCTParagraphStyleSpecifierLineHeightMultiple
		// So directly add them to lineOrigin.y
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
	
	// preserve own baseline x
	lineOrigin.x = line.baselineOrigin.x;
	
	// prevent overlap of a line with small font size with line before it
	if (!usesForcedLineHeight)
	{
		// only if there IS a line before it AND the line height is not fixed
		CGFloat previousLineBottom = CGRectGetMaxY(previousLine.frame);
		
		if (lineOrigin.y - line.ascent < previousLineBottom)
		{
			// move baseline origin down far enough
			lineOrigin.y = previousLineBottom + line.ascent;
		}
	}
	
	// origins are rounded
	lineOrigin.y = ceil(lineOrigin.y);
	
	return lineOrigin;
}

- (CGRect)intrinsicContentFrame
{
	if (![self.lines count])
	{
		return CGRectZero;
	}
	
	NBTextLine *firstLine = [_lines objectAtIndex:0];
	
	CGRect outerFrame = _frame;
	
	CGRect frameOverAllLines = firstLine.frame;
	
	// move up to frame origin because first line usually does not go all the ways up
	frameOverAllLines.origin.y = outerFrame.origin.y;
	
	for (NBTextLine *oneLine in _lines)
	{
		// need to limit frame to outer frame, otherwise HR causes too long lines
		CGRect frame = CGRectIntersection(oneLine.frame, outerFrame);
		
		frameOverAllLines = CGRectUnion(frame, frameOverAllLines);
	}
	
	// extend height same method as frame
	frameOverAllLines.size.height = ceil(frameOverAllLines.size.height + 1.5f + _additionalPaddingAtBottom);
	
	return CGRectIntegral(frameOverAllLines);
}

#pragma mark - Calculations

- (NSRange)visibleStringRange
{
//	if (!_textFrame)
//	{
//		return NSMakeRange(0, 0);
//	}
	
	return _stringRange;
}

- (NSArray *)stringIndices
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self.lines count]];
	
	for (NBTextLine *oneLine in self.lines)
	{
		[array addObjectsFromArray:[oneLine stringIndices]];
	}
	
	return array;
}

- (CGRect)getDefaultFrameShowRect
{
	if (![self.lines count])
	{
		return CGRectZero;
	}
	
	if (_frame.size.height == CGFLOAT_HEIGHT_UNKNOWN)
	{
		// actual frame is spanned between first and last lines
		NBTextLine *lastLine = [_lines lastObject];
		
		_frame.size.height = ceil((CGRectGetMaxY(lastLine.frame) - _frame.origin.y + 1.5f + _additionalPaddingAtBottom));
	}
	
	if (_frame.size.width == CGFLOAT_WIDTH_UNKNOWN)
	{
		// actual frame width is maximum value of lines
		CGFloat maxWidth = 0;
		
		for (NBTextLine *oneLine in _lines)
		{
			CGFloat lineWidthFromFrameOrigin = CGRectGetMaxX(oneLine.frame) - _frame.origin.x;
			maxWidth = MAX(maxWidth, lineWidthFromFrameOrigin);
		}
		
		_frame.size.width = ceil(maxWidth);
	}
	
	return _frame;
}


- (NSArray *)getLines
{
	return _lines;
}

- (BOOL)isDashOrEllipsis:(NSString*)lastAndNextChar
{
	BOOL bRet = NO;
	if ([lastAndNextChar length] > 0)
	{
		NSMutableCharacterSet *specialChar = [NSMutableCharacterSet characterSetWithCharactersInString:@"…—"];
		
		NSString* oneChar = [lastAndNextChar substringWithRange:NSMakeRange(0, 1)];
		bRet = [specialChar characterIsMember:[oneChar characterAtIndex:0]];
//		if (bRet)
//		{
//			oneChar = [lastAndNextChar substringWithRange:NSMakeRange(1, 1)];
//			bRet = [specialChar characterIsMember:[oneChar characterAtIndex:0]];
//		}
	}
	
	return bRet;
}

- (BOOL)isSpecialPairChar:(NSString*)lastAndNextChar
{
	BOOL bRet = NO;
	
	if ([lastAndNextChar length] > 1)
	{
		NSString* oneChar = [lastAndNextChar substringWithRange:NSMakeRange(0, 1)];
		if ([self _isSpecialChar:oneChar])
		{
			oneChar = [lastAndNextChar substringWithRange:NSMakeRange(1, 1)];
			//NSMutableCharacterSet *specialChar = [NSMutableCharacterSet characterSetWithCharactersInString:@"'\"’”"];
			//bRet = [specialChar characterIsMember:[oneChar characterAtIndex:0]];
			[self _isSpecialChar:oneChar];
		}
	}
	
	return bRet;
}

- (BOOL)_isSpecialChar:(NSString*)oneChar
{
	BOOL bRet = NO;
	if ([oneChar length] > 0)
	{
		//unichar engcharset[20] = @",.;:?)'\"`!}]>-°′″";
		//unichar chicharset[20] = "。，；？！、：”’）》〉…—﹃〕﹁】﹏～";
//		unichar ch = engcharset[0];
//		ch = chicharset[0];
		const NSString* englishMarkSet = @",.;:?)'\"`!}]>-°′″";
		const NSString* chineseMarkSet = @"。，；？！、：”’）》〉﹃〕﹁】﹏～…—";
		
		NSMutableCharacterSet *specialChar = [NSMutableCharacterSet characterSetWithCharactersInString:(NSString*)englishMarkSet];
		///< 中文
		[specialChar addCharactersInString:(NSString*)chineseMarkSet];
		bRet = [specialChar characterIsMember:[oneChar characterAtIndex:0]];
	}
	
	return bRet;
}

- (BOOL)isSpecialCommaChar:(NSString*)oneChar
{
	BOOL bRet = NO;
	if ([oneChar length] > 0)
	{
		NSMutableCharacterSet *specialChar = [NSMutableCharacterSet characterSetWithCharactersInString:@"!)}]>.?"];
		///< 中文
		[specialChar addCharactersInString:@"！）}】。》？…—,，"];
		bRet = [specialChar characterIsMember:[oneChar characterAtIndex:0]];
	}
	
	return bRet;
}

- (NSInteger)getSpecialCharCount:(NSString*)checkStr
{
	NSInteger nCount = 0;
	
	do
	{
		if ([checkStr length] < 1)
		{
			break;
		}
		
		BOOL bSpecChar = NO;
		
		bSpecChar = [self _isSpecialChar:checkStr];
		if (bSpecChar)
		{
			nCount = 1;
		}
		
		if (bSpecChar && [checkStr length] == 2)
		{
			bSpecChar = [self isDashOrEllipsis:[checkStr substringFromIndex:1]];
			///< 如果是破折号
			if (bSpecChar)
			{
				bSpecChar = NO;
			}
			else
			{
				bSpecChar = [self _isSpecialChar:[checkStr substringFromIndex:1]];
			}
			
			if (bSpecChar)
			{
				nCount = 2;
			}
		}
		
	}while (0);
	
	return nCount;
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
	
	// need the paragraph ranges to know if a line is at the beginning of paragraph
	NSMutableArray *paragraphRanges = [[self paragraphRanges] mutableCopy];
	
	NSRange currentParagraphRange = [[paragraphRanges objectAtIndex:0] rangeValue];
	
	NSRange lineRange = _stringRange;
	
	
	CGFloat maxY = CGRectGetMaxY(_frame);
	NSUInteger maxIndex = NSMaxRange(_stringRange);
	NSUInteger fittingLength = 0;
	
	BOOL shouldTruncateLine = NO;
	
	do
	{
		BOOL bEnd = NO;
		while (lineRange.location >= (currentParagraphRange.location+currentParagraphRange.length))
		{
			// we are outside of this paragraph, so we go to the next
			[paragraphRanges removeObjectAtIndex:0];
			if ([paragraphRanges count] > 0)
			{
				currentParagraphRange = [[paragraphRanges objectAtIndex:0] rangeValue];
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
		
		BOOL isAtBeginOfParagraph = (currentParagraphRange.location == lineRange.location);
		
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
		if (![[[_attrString string] substringWithRange:NSMakeRange(lineRange.location, 1)] isEqualToString:@"\t"])
		{
			offset += headIndent;
		}
		
		//lineRange.length = CTTypesetterSuggestLineBreak(typesetter, lineRange.location, availableWidth); ///< use kCTLineBreakByWordWrapping
		lineRange.length = CTTypesetterSuggestClusterBreak(typesetter, lineRange.location, availableWidth);
		
		if (NSMaxRange(lineRange) > maxIndex)
		{
			// only layout as much as was requested
			lineRange.length = maxIndex - lineRange.location;
		}
		
		
		NSString* checkStr = nil;
		if (NSMaxRange(lineRange) + 2 <= maxIndex)
		{
			NSRange rangeObj = NSMakeRange(lineRange.location + lineRange.length, 2);
			checkStr = [[_attrString string] substringWithRange:rangeObj];
		}
		else
		{
			if (NSMaxRange(lineRange) + 1 <= maxIndex)
			{
				NSRange rangeObj = NSMakeRange(lineRange.location + lineRange.length, 1);
				checkStr = [[_attrString string] substringWithRange:rangeObj];
			}
		}
		
		NSInteger nCount = [self getSpecialCharCount:checkStr];
		if (nCount > 0)
		{
			lineRange.length += nCount;
			
#ifdef ENABLE_NBLayoutFrame_Debug
			NSString *lineString = [[_attrString attributedSubstringFromRange:lineRange] string];
			unichar ch = [lineString characterAtIndex:[lineString length] + nCount -1];
			NSString* lastChar = [lineString substringFromIndex:[lineString length] - 1];
			
			NSLog(@"lineString=[L:%d][c:%d][ch:%d,%@,%@][%@]", [typesetLines count], [lineString length], ch, lastChar, lastNextChar, lineString);
#endif
		}
		
		CTLineRef line;
		
		// create a line to fit
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
		
		if (nCount)
		{
			textAlignment = kCTJustifiedTextAlignment; ///< 手动的行调整
		}
		
		NSAttributedString *attribStr = nil;
		switch (textAlignment)
		{
			case kCTLeftTextAlignment:
			{
				lineOriginX = _frame.origin.x + offset;
				// nothing to do
				break;
			}
			case kCTJustifiedTextAlignment:
			{
				NSRange newLineRange = lineRange;
				NSString *lineString = [[_attrString attributedSubstringFromRange:newLineRange] string];
				
				NSRange range;
				NSDictionary * attributes = [_attrString attributesAtIndex:lineRange.location effectiveRange:&range];
				
				attribStr = [[NSAttributedString alloc] initWithString:lineString attributes:attributes];
				
				CTLineRef elipsisLineRef = CTLineCreateWithAttributedString((__bridge  CFAttributedStringRef)(attribStr));
				
				CTLineRef justifiedLine = elipsisLineRef;
				if (justifiedLine)
				{
					CFRelease(line);
					line = justifiedLine;
				}
#if 0
				BOOL isAtEndOfParagraph  = (currentParagraphRange.location+currentParagraphRange.length <= lineRange.location+lineRange.length ||
				[[_attrString string] characterAtIndex:lineRange.location+lineRange.length-1]==0x2028);
				
				// only justify if not last line, not <br>, and if the line width is longer than _justifyRatio of the frame
				// avoids over-stretching
				if( !isAtEndOfParagraph && (currentLineWidth > _justifyRatio * _frame.size.width) )
				{
					// create a justified line and replace the current one with it
					//CTLineRef justifiedLine = CTLineCreateJustifiedLine(elipsisLineRef, 1.0f, availableWidth);
					
					CTLineRef justifiedLine = elipsisLineRef;
					
					// CTLineCreateJustifiedLine sometimes fails if the line ends with 0x00AD (soft hyphen) and contains cyrillic chars
					if (justifiedLine)
					{
						CFRelease(line);
						line = justifiedLine;
					}
				}
				else if (!isAtEndOfParagraph)
				{
					// create a justified line and replace the current one with it
					//CTLineRef justifiedLine = CTLineCreateJustifiedLine(elipsisLineRef, 1.0f, availableWidth);
					CTLineRef justifiedLine = elipsisLineRef;
					
					// CTLineCreateJustifiedLine sometimes fails if the line ends with 0x00AD (soft hyphen) and contains cyrillic chars
					if (justifiedLine)
					{
						CFRelease(line);
						line = justifiedLine;
					}
				}
#endif
				currentLineWidth = (CGFloat)CTLineGetTypographicBounds(line, NULL, NULL, NULL);
				
				if (isRTL)
				{
					// align line with right margin
					lineOriginX = _frame.origin.x + offset + (CGFloat)CTLineGetPenOffsetForFlush(line, 1.0, availableWidth);
				}
				else
				{
					// align line with left margin
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
		newLine.text = [attribStr string];
		newLine.writingDirectionIsRightToLeft = isRTL;
		CFRelease(line);
		
		CGPoint newLineBaselineOrigin = [self _algorithmLegacy_BaselineOriginToPositionLine:newLine afterLine:previousLine];
		newLineBaselineOrigin.x = lineOriginX;
		newLine.baselineOrigin = newLineBaselineOrigin;
		
		CGFloat lineBottom = CGRectGetMaxY(newLine.frame);
		
		if (lineBottom>maxY)
		{
			if ([typesetLines count])
			{
				_numberLinesFitInFrame = [typesetLines count];
				
				bRet = YES;
				break;
			}
			else
			{
				// doesn't fit any more
				break;
			}
		}
		
		[typesetLines addObject:newLine];
		fittingLength += lineRange.length;
		
		lineRange.location += lineRange.length;
		previousLine = newLine;
		
	}while (lineRange.location < maxIndex && !shouldTruncateLine);
	
	_lines = typesetLines;
	
	if (![_lines count])
	{
		// no lines fit
		_stringRange = NSMakeRange(0, 0);
		
		return bRet;
	}
	bRet = YES;
	// now we know how many characters fit
	_stringRange.location = _stringRange.location;
	_stringRange.length = fittingLength;
	
	[self updateLinesOriginInRect:frame];
	
	return bRet;
}

- (void)updateLinesOriginInRect:(CGRect)frame
{
	NSArray *lineList = _lines;
	for (NBTextLine* lineObj in lineList)
	{
		CGPoint origin = lineObj.baselineOrigin;
		CGFloat h = lineObj.descent + lineObj.ascent + lineObj.leading;
		h = lineObj.ascent;
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
	NSArray *lineList = _lines;
	for (NBTextLine* lineObj in lineList)
	{
		[lineObj drawLinesWith:context inRect:rect];
	}
}

@end

