
#import "NSString+Paragraphs.h"

@implementation NSString (Paragraphs)

- (NSRange)rangeOfParagraphsContainingRange:(NSRange)range parBegIndex:(NSUInteger *)parBegIndex parEndIndex:(NSUInteger *)parEndIndex
{
	CFIndex beginIndex;
	CFIndex endIndex;
	
	CFStringGetParagraphBounds((__bridge CFStringRef)self, CFRangeMake(range.location, range.length), &beginIndex, &endIndex, NULL);
	
	if (parBegIndex)
	{
		*parBegIndex = beginIndex;
	}
	
	if (parEndIndex)
	{
		*parEndIndex = endIndex;
	}
	
	return NSMakeRange(beginIndex, endIndex - beginIndex);
}

- (BOOL)indexIsAtBeginningOfParagraph:(NSUInteger)index
{
	if (!index)
	{
		return YES;
	}
	
	if ([self characterAtIndex:index-1] == '\n')
	{
		return YES;
	}
	
	return NO;
}

- (NSRange)rangeOfParagraphAtIndex:(NSUInteger)index
{
	return [self rangeOfParagraphsContainingRange:NSMakeRange(index, 1) parBegIndex:NULL parEndIndex:NULL];
}

- (NSUInteger)numberOfParagraphs
{
	NSUInteger retValue = 0;
	
	for (NSUInteger i=0; i<[self length]; i++)
	{
		if ([self characterAtIndex:i] == '\n')
		{
			retValue++;
		}
	}
	
	return retValue;
}

@end
