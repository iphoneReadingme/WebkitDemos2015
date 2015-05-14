
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBLayouterHelper.h
 *
 * Description	: NBLayouterHelper
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-14.
 * History		: modify: 2015-05-14.
 *
 ******************************************************************************
 **/



#import "NBLayouterHelper.h"


@interface NBLayouterHelper ()

@end


@implementation NBLayouterHelper


+ (BOOL)printTest:(unichar)checkChar
{
	BOOL bRet = NO;
	//unichar engCharset[17] = {',', '.', ';', ':', '?', ')', '\'', '\"', '`', '!', '}', ']', '>', '-', '°', 0, 0, 0};
	//unichar chiCharset[24] = {'。', '，', '；', '？', '！', '、', '：', '”', '’', '′', '″', '）', '》', '〉', '」', '﹃', '〕', '﹁', '】', '﹏', '～', '…', '—', '』', '〗'};
	unichar engCharset[20] = {0};
	unichar chiCharset[30] = {0};
	unichar chiCharset2[30] = {0};
	
	const NSString* englishMarkSet = @",.;:?)'\"`!}]>-";
	const NSString* chineseMarkSet = @"。，；？！、：”’′″）》〉」﹃〕﹁】﹏～…—』〗°";
	const NSString* chineseMarkSet2 = @"({[<“‘（｛《〈﹄﹂〔【「『〖";
	
	NSMutableString* temp = [NSMutableString stringWithCapacity:2];
	[temp setString:@"\n"];
	int i = 0;
	for (; i < [englishMarkSet length]; i++)
	{
		engCharset[i] = [englishMarkSet characterAtIndex:i];
		//[temp appendFormat:@"'%@', ", [englishMarkSet substringWithRange:NSMakeRange(i, 1)]];
		[temp appendFormat:@"case %d: // %@\n{\n	bRet = YES;\n	break;\n}\n ", engCharset[i], [englishMarkSet substringWithRange:NSMakeRange(i, 1)]];
	}
	engCharset[i++] = 126;
	engCharset[i++] = 127;
	
	NSLog(@"%@", temp);
	[temp setString:@"\n"];
	
	i = 0;
	for (; i < [chineseMarkSet length]; i++)
	{
		chiCharset[i] = [chineseMarkSet characterAtIndex:i];
		//[temp appendFormat:@"'%@', ", [chineseMarkSet substringWithRange:NSMakeRange(i, 1)]];
		//[temp appendFormat:@"%d, ", chiCharset[i]];
		[temp appendFormat:@"case %d: // %@\n{\n	bRet = YES;\n	break;\n}\n ", chiCharset[i], [chineseMarkSet substringWithRange:NSMakeRange(i, 1)]];
	}
	
	NSLog(@"%@", temp);
	[temp setString:@"\n"];
	
	i = 0;
	for (; i < [chineseMarkSet2 length]; i++)
	{
		chiCharset2[i] = [chineseMarkSet2 characterAtIndex:i];
		//[temp appendFormat:@"'%@', ", [chineseMarkSet substringWithRange:NSMakeRange(i, 1)]];
		//[temp appendFormat:@"%d, ", chiCharset[i]];
		[temp appendFormat:@"case %d: // %@\n{\n	bRet = YES;\n	break;\n}\n ", chiCharset2[i], [chineseMarkSet2 substringWithRange:NSMakeRange(i, 1)]];
	}
	
	NSLog(@"%@", temp);
	[temp setString:@"\n"];
	
	
	return bRet;
}

+ (BOOL)isDashOrEllipsis:(NSString*)oneChar
{
	BOOL bRet = NO;
	if ([oneChar length] > 0)
	{
		switch ([oneChar characterAtIndex:0])
		{
		case 8230: // …
			{
				bRet = YES;
				break;
			}
		case 8212: // —
			{
				bRet = YES;
				break;
			}
		default:
			{
				break;
			}
		}
		//NSMutableCharacterSet *specialChar = [NSMutableCharacterSet characterSetWithCharactersInString:@"…—"];
		
		//bRet = [specialChar characterIsMember:[oneChar characterAtIndex:0]];
	}
	
	return bRet;
}

+ (BOOL)isPrePartOfPairMarkChar:(NSString*)oneChar
{
	BOOL bRet = NO;
	if ([oneChar length] > 0)
	{
		bRet =[self isPrePartOfPairMarkChar2:[oneChar characterAtIndex:0]];
//		NSMutableCharacterSet *specialChar = [NSMutableCharacterSet characterSetWithCharactersInString:@"({[<"];
		
//		[specialChar addCharactersInString:@"“‘（｛《〈﹄﹂〔【「『〖"];
//		bRet = [specialChar characterIsMember:[oneChar characterAtIndex:0]];
	}
	
	return bRet;
}

+ (BOOL)isSpecialMarkChar:(NSString*)oneChar
{
	BOOL bRet = NO;
	if ([oneChar length] > 0)
	{
		///< 进一步区分中英语，以提高效率
		//[self printTest:[oneChar characterAtIndex:0]];
		unichar markChar = [oneChar characterAtIndex:0];
		bRet = [self isASCIICodeMarkChar:markChar] || [self isUniCodeMarkChar:markChar];
		
//		const NSString* englishMarkSet = @",.;:?)'\"`!}]>-";
//		const NSString* chineseMarkSet = @"。，；？！、：”’′″）》〉」﹃〕﹁】﹏～…—』〗°";
//		NSMutableCharacterSet *specialChar = [NSMutableCharacterSet characterSetWithCharactersInString:(NSString*)englishMarkSet];
//		
//		[specialChar addCharactersInString:(NSString*)chineseMarkSet];
//		bRet = [specialChar characterIsMember:[oneChar characterAtIndex:0]];
	}
	
	return bRet;
}

+ (NSInteger)getSpecialMarkCharCount:(NSString*)checkStr
{
	NSInteger nCount = 0;
	
	do
	{
		if ([checkStr length] < 1)
		{
			break;
		}
		
		BOOL bFirstSpecChar = NO;
		BOOL bSecondSpecChar = NO;
		
		if ([checkStr length] == 2)
		{
			bFirstSpecChar = [NBLayouterHelper isDashOrEllipsis:[checkStr substringFromIndex:0]];
			
			if (bFirstSpecChar)
			{
				bSecondSpecChar = [NBLayouterHelper isDashOrEllipsis:[checkStr substringFromIndex:1]];
			}
			else
			{
				bFirstSpecChar = [NBLayouterHelper isSpecialMarkChar:[checkStr substringFromIndex:0]];
			}
			
			if (bSecondSpecChar)
			{
				break;
			}
			
			if (bFirstSpecChar)
			{
				bSecondSpecChar = [NBLayouterHelper isSpecialMarkChar:[checkStr substringFromIndex:1]];
			}
		}
		else
		{
			bFirstSpecChar = [NBLayouterHelper isSpecialMarkChar:[checkStr substringFromIndex:0]];
		}
		
		if (bFirstSpecChar)
		{
			nCount = bSecondSpecChar ? 2 : 1;
		}
		
	}while (0);
	
	return nCount;
}

///< 本行尾部特殊字符
+ (NSInteger)getEndSpecialMarkCharCount:(NSString*)checkStr
{
	NSInteger nCount = 0;
	
	do
	{
		if ([checkStr length] < 1)
		{
			break;
		}
		
		BOOL bFirstSpecChar = NO;
		BOOL bSecondSpecChar = NO;
		
		if ([checkStr length] == 2)
		{
			bFirstSpecChar = [NBLayouterHelper isDashOrEllipsis:[checkStr substringFromIndex:0]];
			
			if (bFirstSpecChar)
			{
				bSecondSpecChar = [NBLayouterHelper isDashOrEllipsis:[checkStr substringFromIndex:1]];
			}
			else
			{
				bFirstSpecChar = [NBLayouterHelper isSpecialMarkChar:[checkStr substringFromIndex:0]];
			}
			
			if (bSecondSpecChar)
			{
				break;
			}
			
			if (bFirstSpecChar)
			{
				bSecondSpecChar = [NBLayouterHelper isSpecialMarkChar:[checkStr substringFromIndex:1]];
			}
		}
		else
		{
			bFirstSpecChar = [NBLayouterHelper isSpecialMarkChar:[checkStr substringFromIndex:0]];
		}
		
		if (bFirstSpecChar)
		{
			nCount = bSecondSpecChar ? 2 : 1;
		}
		
	}while (0);
	
	return nCount;
}

+ (BOOL)isASCIICodeMarkChar:(unichar)markChar
{
	BOOL bRet = NO;
	
	switch (markChar)
	{
		case 44: // ,
		{
			bRet = YES;
			break;
		}
		case 46: // .
		{
			bRet = YES;
			break;
		}
		case 59: // ;
		{
			bRet = YES;
			break;
		}
		case 58: // :
		{
			bRet = YES;
			break;
		}
		case 63: // ?
		{
			bRet = YES;
			break;
		}
		case 41: // )
		{
			bRet = YES;
			break;
		}
		case 39: // '
		{
			bRet = YES;
			break;
		}
		case 34: // "
		{
			bRet = YES;
			break;
		}
		case 96: // `
		{
			bRet = YES;
			break;
		}
		case 33: // !
		{
			bRet = YES;
			break;
		}
		case 125: // }
		{
			bRet = YES;
			break;
		}
		case 93: // ]
		{
			bRet = YES;
			break;
		}
		case 62: // >
		{
			bRet = YES;
			break;
		}
		case 45: // -
		{
			bRet = YES;
			break;
		}
		default:
		{
			break;
		}
	}
	
	return bRet;
}

+ (BOOL)isUniCodeMarkChar:(unichar)markChar
{
	BOOL bRet = NO;
	
	switch (markChar)
	{
		case 12290: // 。
		{
			bRet = YES;
			break;
		}
		case 65292: // ，
		{
			bRet = YES;
			break;
		}
		case 65307: // ；
		{
			bRet = YES;
			break;
		}
		case 65311: // ？
		{
			bRet = YES;
			break;
		}
		case 65281: // ！
		{
			bRet = YES;
			break;
		}
		case 12289: // 、
		{
			bRet = YES;
			break;
		}
		case 65306: // ：
		{
			bRet = YES;
			break;
		}
		case 8221: // ”
		{
			bRet = YES;
			break;
		}
		case 8217: // ’
		{
			bRet = YES;
			break;
		}
		case 8242: // ′
		{
			bRet = YES;
			break;
		}
		case 8243: // ″
		{
			bRet = YES;
			break;
		}
		case 65289: // ）
		{
			bRet = YES;
			break;
		}
		case 12299: // 》
		{
			bRet = YES;
			break;
		}
		case 12297: // 〉
		{
			bRet = YES;
			break;
		}
		case 12301: // 」
		{
			bRet = YES;
			break;
		}
		case 65091: // ﹃
		{
			bRet = YES;
			break;
		}
		case 12309: // 〕
		{
			bRet = YES;
			break;
		}
		case 65089: // ﹁
		{
			bRet = YES;
			break;
		}
		case 12305: // 】
		{
			bRet = YES;
			break;
		}
		case 65103: // ﹏
		{
			bRet = YES;
			break;
		}
		case 65374: // ～
		{
			bRet = YES;
			break;
		}
		case 8230: // …
		{
			bRet = YES;
			break;
		}
		case 8212: // —
		{
			bRet = YES;
			break;
		}
		case 12303: // 』
		{
			bRet = YES;
			break;
		}
		case 12311: // 〗
		{
			bRet = YES;
			break;
		}
		case 176: // °
		{
			bRet = YES;
			break;
		}
		default:
		{
			break;
		}
	}
	
	return bRet;
}

+ (BOOL)isPrePartOfPairMarkChar2:(unichar)markChar
{
	BOOL bRet = NO;
	
	switch (markChar)
	{
		case 40: // (
		{
			bRet = YES;
			break;
		}
		case 123: // {
		{
			bRet = YES;
			break;
		}
		case 91: // [
		{
			bRet = YES;
			break;
		}
		case 60: // <
		{
			bRet = YES;
			break;
		}
		case 8220: // “
		{
			bRet = YES;
			break;
		}
		case 8216: // ‘
		{
			bRet = YES;
			break;
		}
		case 65288: // （
		{
			bRet = YES;
			break;
		}
		case 65371: // ｛
		{
			bRet = YES;
			break;
		}
		case 12298: // 《
		{
			bRet = YES;
			break;
		}
		case 12296: // 〈
		{
			bRet = YES;
			break;
		}
		case 65092: // ﹄
		{
			bRet = YES;
			break;
		}
		case 65090: // ﹂
		{
			bRet = YES;
			break;
		}
		case 12308: // 〔
		{
			bRet = YES;
			break;
		}
		case 12304: // 【
		{
			bRet = YES;
			break;
		}
		case 12300: // 「
		{
			bRet = YES;
			break;
		}
		case 12302: // 『
		{
			bRet = YES;
			break;
		}
		case 12310: // 〖
		{
			bRet = YES;
			break;
		}
		default:
		{
			break;
		}
	}
	
	return bRet;
}

@end

