
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

@property (nonatomic, assign) CGFloat                   additionalPaddingAtBottom;
@property (nonatomic, assign) CGFloat                   justifyRatio;
@property(nonatomic, assign) NSLineBreakMode            lineBreakMode;
@property(nonatomic, copy) NSAttributedString           *truncationString;
@property (nonatomic, copy) NSAttributedString          *attrString;


@end


@implementation NBTextLayoutFrame


- (void)dealloc
{
	[self destoryTextFrame];
	[self destoryFrameSetter];
	
	[super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame with:(NSAttributedString *)attrString range:(NSRange)range
{
	self = [super init];
	
	if (self)
	{
		// determine correct target range
		_stringRange = range;
		NSUInteger stringLength = [attrString length];
		
		if (_stringRange.location >= stringLength)
		{
			return nil;
		}
		
		_frame = frame;
		_attrString = [attrString mutableCopy];
		
		if (_stringRange.length==0 || NSMaxRange(_stringRange) > stringLength)
		{
			_stringRange.length = stringLength - _stringRange.location;
		}
		
		_justifyRatio = 0.6f;
	}
	
	return self;
}

- (void)destoryTextFrame
{
	if (_textFrame)
	{
		CFRelease(_textFrame);
		_textFrame = nil;
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

- (CTFramesetterRef)getFramesetter
{
	[self _createFramesetter];
	
	return _framesetter;
}

///< 根据 attrString 创建相关frame
- (void)framesetterCreateDefaultFrame
{
	[self _createFramesetter];
	
	CFRange cfRange = CFRangeMake(_stringRange.location, _stringRange.length);
	
	if (_framesetter)
	{
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, _frame);
		
		_textFrame = CTFramesetterCreateFrame(_framesetter, cfRange, path, NULL);
		
		CGPathRelease(path);
	}
	else
	{
		// Strange, should have gotten a valid framesetter
		//return nil;
		assert(false);
	}
}

- (void)_createFramesetter
{
	if (nil == _framesetter)
	{
		///< 创建framesetter
		_framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attrString);
	}
}

- (BOOL)createRangeFrameWithRange:(NSRange)strRange rect:(CGRect)rect out:(CTFrameRef &)rangeFrame
{
	BOOL bRet = NO;
	do
	{
		[self _createFramesetter];
		
		if (nil == _framesetter)
		{
			break;
		}
		
		if (strRange.length < 1
			|| strRange.location + strRange.length > _stringRange.length
			)
		{
			break;
		}
		
		CFRange cfRange = CFRangeMake(strRange.location, strRange.length);
		
		CGMutablePathRef framePath = CGPathCreateMutable();
		if (nil == framePath)
		{
			break;
		}
		CGPathAddRect(framePath, &CGAffineTransformIdentity, rect);
		rangeFrame = CTFramesetterCreateFrame(_framesetter, cfRange, framePath, NULL);
		
		bRet = (rangeFrame != nil);
		
	}while (0);
	
	return bRet;
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

- (NSArray *)lines
{
	if (!_lines)
	{
		[self _buildLines];
	}
	
	return _lines;
}

- (void)_buildLines
{
	// only build lines if frame is legal
	if (_frame.size.width<=0)
	{
		return;
	}
	
	// note: building line by line with typesetter
	[self _buildLinesWithTypesetter];
	
	//[self _buildLinesWithStandardFramesetter];
}

- (void)_buildLinesWithTypesetter
{
	// framesetter keeps internal reference, no need to retain
	CTTypesetterRef typesetter = CTFramesetterGetTypesetter(_framesetter);
	
	NSMutableArray *typesetLines = [NSMutableArray array];
	
	NBTextLine *previousLine = nil;
	
	// need the paragraph ranges to know if a line is at the beginning of paragraph
	NSMutableArray *paragraphRanges = [[self paragraphRanges] mutableCopy];
	
	NSRange currentParagraphRange = [[paragraphRanges objectAtIndex:0] rangeValue];
	
	// we start out in the requested range, length will be set by the suggested line break function
	NSRange lineRange = _stringRange;
	
	// maximum values for abort of loop
	CGFloat maxY = CGRectGetMaxY(_frame);
	NSUInteger maxIndex = NSMaxRange(_stringRange);
	NSUInteger fittingLength = 0;
	BOOL shouldTruncateLine = NO;
	
	do  // for each line
	{
		while (lineRange.location >= (currentParagraphRange.location+currentParagraphRange.length))
		{
			// we are outside of this paragraph, so we go to the next
			[paragraphRanges removeObjectAtIndex:0];
			
			currentParagraphRange = [[paragraphRanges objectAtIndex:0] rangeValue];
		}
		
		BOOL isAtBeginOfParagraph = (currentParagraphRange.location == lineRange.location);
		
		CGFloat headIndent = 0;
		CGFloat tailIndent = 0;
		
		// get the paragraph style at this index
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
		
		// add left padding to offset
		CGFloat lineOriginX;
		CGFloat availableSpace;
		
//		NSString * const DTTextBlocksAttribute = @"DTTextBlocks";
//		NSArray *textBlocks = [_attrString attribute:DTTextBlocksAttribute atIndex:lineRange.location effectiveRange:NULL];
		CGFloat totalLeftPadding = 0;
		CGFloat totalRightPadding = 0;
		
//		for (DTTextBlock *oneTextBlock in textBlocks)
//		{
//			totalLeftPadding += oneTextBlock.padding.left;
//			totalRightPadding += oneTextBlock.padding.right;
//		}
		
		if (tailIndent<=0)
		{
			// negative tail indent is measured from trailing margin (we assume LTR here)
			availableSpace = _frame.size.width - headIndent - totalRightPadding + tailIndent - totalLeftPadding;
		}
		else
		{
			availableSpace = tailIndent - headIndent - totalLeftPadding - totalRightPadding;
		}
		
		
		CGFloat offset = totalLeftPadding;
		
		// if first character is a tab, then it is positioned without the indentation
		if (![[[_attrString string] substringWithRange:NSMakeRange(lineRange.location, 1)] isEqualToString:@"\t"])
		{
			offset += headIndent;
		}
		
		// find how many characters we get into this line
		lineRange.length = CTTypesetterSuggestLineBreak(typesetter, lineRange.location, availableSpace);
		
		if (NSMaxRange(lineRange) > maxIndex)
		{
			// only layout as much as was requested
			lineRange.length = maxIndex - lineRange.location;
		}
		
		
		// determine whether this is a normal line or if it should be truncated
		shouldTruncateLine = ((self.numberOfLines>0 && [typesetLines count]+1==self.numberOfLines) || (_numberLinesFitInFrame>0 && _numberLinesFitInFrame==[typesetLines count]+1));
		
		CTLineRef line;
		BOOL isHyphenatedString = NO;
		
		if (!shouldTruncateLine)
		{
			static const unichar softHypen = 0x00AD;
			NSString *lineString = [[_attrString attributedSubstringFromRange:lineRange] string];
			unichar lastChar = [lineString characterAtIndex:[lineString length] - 1];
			if (softHypen == lastChar)
			{
				NSMutableAttributedString *hyphenatedString = [[_attrString attributedSubstringFromRange:lineRange] mutableCopy];
				NSRange replaceRange = NSMakeRange(hyphenatedString.length - 1, 1);
				[hyphenatedString replaceCharactersInRange:replaceRange withString:@"-"];
				line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)hyphenatedString);
				isHyphenatedString = YES;
			}
			else
			{
				// create a line to fit
				line = CTTypesetterCreateLine(typesetter, CFRangeMake(lineRange.location, lineRange.length));
			}
		}
		else
		{
			// extend the line to the end of the current paragraph
			// if we extend to the entire to the entire text range
			// it is possible to pull lines up from paragraphs below us
			NSRange oldLineRange = lineRange;
			lineRange.length = NSMaxRange(currentParagraphRange)-lineRange.location;
			CTLineRef baseLine = CTTypesetterCreateLine(typesetter, CFRangeMake(lineRange.location, lineRange.length));
			
			// convert lineBreakMode to CoreText type
			CTLineTruncationType truncationType = [self lineTruncationTypeFromNSLineBreakMode:_lineBreakMode];
			
			// prepare truncation string
			NSAttributedString * attribStr = self.truncationString;
			if(attribStr == nil)
			{
				NSRange range;
				NSInteger index = oldLineRange.location;
				if (truncationType == kCTLineTruncationEnd)
				{
					index += (oldLineRange.length > 0 ? oldLineRange.length - 1 : 0);
				}
				else if (truncationType == kCTLineTruncationMiddle)
				{
					index += (oldLineRange.length > 1 ? (oldLineRange.length/2.0 - 1) : 0);
				}
				NSDictionary * attributes = [_attrString attributesAtIndex:index effectiveRange:&range];
				attribStr = [[NSAttributedString alloc] initWithString:@"…" attributes:attributes];
			}
			
			CTLineRef elipsisLineRef = CTLineCreateWithAttributedString((__bridge  CFAttributedStringRef)(attribStr));
			
			// create the truncated line
			line = CTLineCreateTruncatedLine(baseLine, availableSpace, truncationType, elipsisLineRef);
			
			// clean up
			CFRelease(baseLine);
			CFRelease(elipsisLineRef);
		}
		
		// we need all metrics so get the at once
		CGFloat currentLineWidth = (CGFloat)CTLineGetTypographicBounds(line, NULL, NULL, NULL);
		
		// adjust lineOrigin based on paragraph text alignment
		CTTextAlignment textAlignment;
		
		if (!CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment))
		{
			textAlignment = kCTNaturalTextAlignment;
		}
		
		// determine writing direction
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
		
		switch (textAlignment)
		{
			case kCTLeftTextAlignment:
			{
				lineOriginX = _frame.origin.x + offset;
				// nothing to do
				break;
			}
				
			case kCTNaturalTextAlignment:
			{
				lineOriginX = _frame.origin.x + offset;
				
				if (baseWritingDirection != kCTWritingDirectionRightToLeft)
				{
					break;
				}
				
				// right alignment falls through
			}
				
			case kCTRightTextAlignment:
			{
				lineOriginX = _frame.origin.x + offset + (CGFloat)CTLineGetPenOffsetForFlush(line, 1.0, availableSpace);
				
				break;
			}
				
			case kCTCenterTextAlignment:
			{
				lineOriginX = _frame.origin.x + offset + (CGFloat)CTLineGetPenOffsetForFlush(line, 0.5, availableSpace);
				
				break;
			}
				
			case kCTJustifiedTextAlignment:
			{
				BOOL isAtEndOfParagraph  = (currentParagraphRange.location+currentParagraphRange.length <= lineRange.location+lineRange.length ||
											[[_attrString string] characterAtIndex:lineRange.location+lineRange.length-1]==0x2028);
				
				// only justify if not last line, not <br>, and if the line width is longer than _justifyRatio of the frame
				// avoids over-stretching
				if( !isAtEndOfParagraph && (currentLineWidth > _justifyRatio * _frame.size.width) )
				{
					// create a justified line and replace the current one with it
					CTLineRef justifiedLine = CTLineCreateJustifiedLine(line, 1.0f, availableSpace);
					
					// CTLineCreateJustifiedLine sometimes fails if the line ends with 0x00AD (soft hyphen) and contains cyrillic chars
					if (justifiedLine)
					{
						CFRelease(line);
						line = justifiedLine;
					}
				}
				
				if (isRTL)
				{
					// align line with right margin
					lineOriginX = _frame.origin.x + offset + (CGFloat)CTLineGetPenOffsetForFlush(line, 1.0, availableSpace);
				}
				else
				{
					// align line with left margin
					lineOriginX = _frame.origin.x + offset;
				}
				
				break;
			}
		}
		
		if (!line)
		{
			continue;
		}
		
		// wrap it
		NBTextLine *newLine = [[NBTextLine alloc] initWithLine:line stringLocationOffset:isHyphenatedString ? lineRange.location : 0];
		newLine.writingDirectionIsRightToLeft = isRTL;
		CFRelease(line);
		
		// determine position of line based on line before it
		
		CGPoint newLineBaselineOrigin = [self _algorithmWebKit_BaselineOriginToPositionLine:newLine afterLine:previousLine];
		newLineBaselineOrigin.x = lineOriginX;
		newLine.baselineOrigin = newLineBaselineOrigin;
		
		// abort layout if we left the configured frame
		CGFloat lineBottom = CGRectGetMaxY(newLine.frame);
		
		if (lineBottom>maxY)
		{
			if ([typesetLines count] && self.lineBreakMode)
			{
				_numberLinesFitInFrame = [typesetLines count];
				[self _buildLinesWithTypesetter];
				
				return;
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
	}
	while (lineRange.location < maxIndex && !shouldTruncateLine);
	
	_lines = typesetLines;
	
	if (![_lines count])
	{
		// no lines fit
		_stringRange = NSMakeRange(0, 0);
		
		return;
	}
	
	// now we know how many characters fit
	_stringRange.location = _stringRange.location;
	_stringRange.length = fittingLength;
	
	// at this point we can correct the frame if it is open-ended
	if (_frame.size.height == CGFLOAT_HEIGHT_UNKNOWN)
	{
		CGFloat totalPadding = 0;
//		NBTextLine *lastLine = [_lines lastObject];
//
//		for (DTTextBlock *oneTextBlock in lastLine.textBlocks)
//		{
//			totalPadding += oneTextBlock.padding.bottom;
//		}
		
		// need to add bottom padding if in text block
		_additionalPaddingAtBottom = totalPadding;
	}
}

- (void)_buildLinesWithStandardFramesetter
{
	// get lines (don't own it so no release)
	CFArrayRef cflines = CTFrameGetLines(_textFrame);
	
	if (!cflines)
	{
		// probably no string set
		return;
	}
	
	CGPoint *origins = (CGPoint*)malloc(sizeof(CGPoint)*CFArrayGetCount(cflines));
	CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, 0), origins);
	
	NSMutableArray *tmpLines = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(cflines)];
	
	NSInteger lineIndex = 0;
	
	for (id oneLine in (__bridge NSArray *)cflines)
	{
		CGPoint lineOrigin = origins[lineIndex];
		
		lineOrigin.y = _frame.size.height - lineOrigin.y + _frame.origin.y;
		lineOrigin.x += _frame.origin.x;
		
		NBTextLine *newLine = [[NBTextLine alloc] initWithLine:(__bridge CTLineRef)oneLine];
		newLine.baselineOrigin = lineOrigin;
		
		[tmpLines addObject:newLine];
		
		lineIndex++;
	}
	free(origins);
	
	_lines = tmpLines;
	
	// need to get the visible range here
	CFRange fittingRange = CTFrameGetStringRange(_textFrame);
	_stringRange.location = fittingRange.location;
	_stringRange.length = fittingRange.length;
}

- (NSArray *)linesVisibleInRect:(CGRect)rect
{
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self.lines count]];
	
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
	
	return 0;
}

- (CGPoint)_algorithmWebKit_BaselineOriginToPositionLine:(NBTextLine *)line afterLine:(NBTextLine *)previousLine
{
	CGPoint baselineOrigin = previousLine.baselineOrigin;
	
	if (previousLine)
	{
		baselineOrigin.y = CGRectGetMaxY(previousLine.frame);
		
		CGFloat halfLeadingFromText = [self _algorithmWebKit_halfLeadingOfLine:previousLine];
		

		{
			baselineOrigin.y += halfLeadingFromText;
		}
		
		// add previous line's after paragraph spacing
		if ([self isLineLastInParagraph:previousLine])
		{
			NBParagraphStyle *paragraphStyle = [previousLine paragraphStyle];
			baselineOrigin.y += paragraphStyle.paragraphSpacing;
		}
	}
	else
	{
		// first line in frame
		baselineOrigin = _frame.origin;
	}
	
	baselineOrigin.y += line.ascent;
	
	CGFloat halfLeadingFromText = [self _algorithmWebKit_halfLeadingOfLine:line];
	
//	if (line.attachments)
//	{
//		// only add half leading if there are no attachments, this prevents line from being shifted up due to negative half leading
//		if (halfLeadingFromText>0)
//		{
//			baselineOrigin.y += halfLeadingFromText;
//		}
//	}
//	else
	{
		baselineOrigin.y += halfLeadingFromText;
	}
	
	NBParagraphStyle *paragraphStyle = [line paragraphStyle];
	
	// add current line's before paragraph spacing
	if ([self isLineFirstInParagraph:line])
	{
		baselineOrigin.y += paragraphStyle.paragraphSpacingBefore;
	}
	
	// add padding for closed text blocks
//	for (DTTextBlock *previousTextBlock in previousLine.textBlocks)
//	{
//		if (![line.textBlocks containsObject:previousTextBlock])
//		{
//			baselineOrigin.y  += previousTextBlock.padding.bottom;
//		}
//	}
	
	// add padding for newly opened text blocks
//	for (DTTextBlock *currentTextBlock in line.textBlocks)
//	{
//		if (![previousLine.textBlocks containsObject:currentTextBlock])
//		{
//			baselineOrigin.y  += currentTextBlock.padding.top;
//		}
//	}
	
	// origins are rounded
	baselineOrigin.y = ceil(baselineOrigin.y);
	
	return baselineOrigin;
}

- (CGRect)intrinsicContentFrame
{
	if (!_lines)
	{
		[self _buildLines];
	}
	
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
	if (!_textFrame)
	{
		return NSMakeRange(0, 0);
	}
	
	if (!_lines)
	{
		// need to build lines to know range
		[self _buildLines];
	}
	
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

@end

