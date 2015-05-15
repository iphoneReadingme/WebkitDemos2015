
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


#define Enable_Unichar_Mothed

@interface NBLayouterHelper ()

@end


@implementation NBLayouterHelper

#if 0
// for test and build all mark char unicode
+ (void)showMaxAndMinChar:(NSInteger)type
{
	NSString* englishMarkSet = @",.;:?)'\"`!}]>-";
	//NSString* englishMarkSet2 = @"({[<“";
	NSString* chineseMarkSet = @"。，；？！、：”’′″）》〉」﹃〕﹁】﹏～…—』〗";
	//NSString* chineseMarkSet = @"。，；？！、：”’′″）》〉」﹃〕﹁】﹏～…—』〗°";
	NSString* chineseMarkSet2 = @"‘（｛《〈﹄﹂〔【「『〖";
	
	NSString* textMarkSet = nil;
	if (type == 1)
	{
		textMarkSet = englishMarkSet;
	}
	if (type == 2)
	{
		textMarkSet = chineseMarkSet;
	}
	if (type == 3)
	{
		textMarkSet = chineseMarkSet2;
	}
	//return;
	NSMutableString* tempString = [NSMutableString stringWithCapacity:2];
	[tempString setString:@"\n"];
	
	unichar charTemp = 0;
	unichar markCharSet[40] = {0};
	int i = 0;
	for (; i < [textMarkSet length]; i++)
	{
		charTemp = markCharSet[i] = [textMarkSet characterAtIndex:i];
		//[temp appendFormat:@"'%@', ", [textMarkSet substringWithRange:NSMakeRange(i, 1)]];
		//[tempString appendFormat:@"%X , [%@], ", markCharSet[i], [textMarkSet substringWithRange:NSMakeRange(i, 1)]];
		//[tempString appendFormat:@"\n%X , [%@], ", charTemp, [textMarkSet substringWithRange:NSMakeRange(i, 1)]];
		//[tempString appendFormat:@"%X ,%X, %X, %X", (charTemp>>12)&0x0f, (charTemp>>8)&0xf, (charTemp>>4)&0xf, (charTemp>>0)&0xf];
		[tempString appendFormat:@"case 0x%X: // %@\n{\n	bRet = YES;\n	break;\n}\n ", markCharSet[i], [textMarkSet substringWithRange:NSMakeRange(i, 1)]];
	}
	NSLog(@"%@", tempString);
	
	NSInteger nCount = [textMarkSet length];
	unichar maxChar = markCharSet[0];
	unichar minChar = markCharSet[0];
	unichar temp = 0;
	
	for (i = 0; i < nCount; i++)
	{
		temp = markCharSet[i];
		if (temp > maxChar)
		{
			maxChar = temp;
		}
		
		if (temp < minChar)
		{
			minChar = temp;
		}
	}
	
	NSLog(@"\n[minChar:%d,[%@]], [minChar:[%d]], %@", minChar, [NSString stringWithCharacters:&minChar length:1], maxChar, [NSString stringWithCharacters:&maxChar length:1]);
}

+ (BOOL)printTest:(unichar)checkChar
{
	BOOL bRet = NO;

	[self showMaxAndMinChar:1];
	
	[self showMaxAndMinChar:2];
	
	[self showMaxAndMinChar:3];
	
	return bRet;
}
#endif

+ (BOOL)isDashOrEllipsis:(unichar)markChar
{
	return (0x2026 == markChar) || (0x2014 == markChar);
}

+ (BOOL)isSpecialMarkChar:(unichar)markChar
{
	BOOL bRet = NO;
	///< 进一步区分中英语，以提高效率
	//[self printTest:[oneChar characterAtIndex:0]];
	
	bRet = [self isASCIICodeMarkChar:markChar];
	
	if (!bRet)
	{
		bRet = [self isUniCodeMarkChar:markChar];
	}
	
	return bRet;
}

+ (NSInteger)getSpecialMarkCharCount:(unichar)nextLineFirstChar with:(unichar)nextLineSecondChar
{
	NSInteger nCount = 0;
	
	do
	{
		NSInteger nCheckCharsCount = 0;
		if (nextLineFirstChar != 0)
		{
			nCheckCharsCount = (nextLineSecondChar == 0) ? 1 : 2;
		}
		
		if (nCheckCharsCount < 1)
		{
			break;
		}
		
		BOOL bFirstSpecChar = NO;
		BOOL bSecondSpecChar = NO;
		
		if (nCheckCharsCount == 2)
		{
			bFirstSpecChar = [NBLayouterHelper isDashOrEllipsis:nextLineFirstChar];
			
			if (bFirstSpecChar)
			{
				bSecondSpecChar = [NBLayouterHelper isDashOrEllipsis:nextLineSecondChar];
			}
			else
			{
				bFirstSpecChar = [NBLayouterHelper isSpecialMarkChar:nextLineFirstChar];
			}
			
			if (bSecondSpecChar)
			{
				break;
			}
			
			if (bFirstSpecChar)
			{
				bSecondSpecChar = [NBLayouterHelper isSpecialMarkChar:nextLineSecondChar];
			}
		}
		else
		{
			bFirstSpecChar = [NBLayouterHelper isSpecialMarkChar:nextLineFirstChar];
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
	
	if (!(0x21 <= markChar && markChar <= 0x7D))
	{
		return bRet;
	}
	///                              {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F};
	static char keyIndexTable1[16] = {0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1};
	//static char keyIndexTable2[16] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1};
	
	if (keyIndexTable1[(markChar >> 4)& 0x0f] && 0x21 <= markChar)
	{
//		NSLog(@"\n====[%X, %d, %@]", markChar, markChar, [NSString stringWithCharacters:&markChar length:1]);
		
		switch (markChar)
		{
			case 0x2C: // ,
			{
				bRet = YES;
				break;
			}
			case 0x2E: // .
			{
				bRet = YES;
				break;
			}
			case 0x3B: // ;
			{
				bRet = YES;
				break;
			}
			case 0x3A: // :
			{
				bRet = YES;
				break;
			}
			case 0x3F: // ?
			{
				bRet = YES;
				break;
			}
			case 0x29: // )
			{
				bRet = YES;
				break;
			}
			case 0x27: // '
			{
				bRet = YES;
				break;
			}
			case 0x22: // "
			{
				bRet = YES;
				break;
			}
			case 0x60: // `
			{
				bRet = YES;
				break;
			}
			case 0x21: // !
			{
				bRet = YES;
				break;
			}
			case 0x7D: // }
			{
				bRet = YES;
				break;
			}
			case 0x5D: // ]
			{
				bRet = YES;
				break;
			}
			case 0x3E: // >
			{
				bRet = YES;
				break;
			}
			case 0x2D: // -
			{
				bRet = YES;
				break;
			}
			default:
			{
				break;
			}
		}
	}
	
	return bRet;
}

+ (BOOL)isUniCodeMarkChar:(unichar)markChar
{
	BOOL bRet = NO;
	
	if (markChar == 176) // °
	{
		return YES;
	}
	if (markChar < 0x2014 || markChar == 0x3000)
	{
		return bRet;
	}
	
	///                              {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F};
	static char keyIndexTable1[16] = {0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1};
	static char keyIndexTable2[16] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1};
	static char keyIndexTable3[16] = {1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	
	if (keyIndexTable1[(markChar >> 12)& 0x0f] && keyIndexTable2[(markChar >> 8)& 0x0f] && keyIndexTable3[(markChar >> 4)& 0x0f])
	{
//		NSLog(@"\n====[%X, %d, %@]", markChar, markChar, [NSString stringWithCharacters:&markChar length:1]);
		switch (markChar)
		{
			case 0x3002: // 。
			{
				bRet = YES;
				break;
			}
			case 0xFF0C: // ，
			{
				bRet = YES;
				break;
			}
			case 0xFF1B: // ；
			{
				bRet = YES;
				break;
			}
			case 0xFF1F: // ？
			{
				bRet = YES;
				break;
			}
			case 0xFF01: // ！
			{
				bRet = YES;
				break;
			}
			case 0x3001: // 、
			{
				bRet = YES;
				break;
			}
			case 0xFF1A: // ：
			{
				bRet = YES;
				break;
			}
			case 0x201D: // ”
			{
				bRet = YES;
				break;
			}
			case 0x2019: // ’
			{
				bRet = YES;
				break;
			}
			case 0x2032: // ′
			{
				bRet = YES;
				break;
			}
			case 0x2033: // ″
			{
				bRet = YES;
				break;
			}
			case 0xFF09: // ）
			{
				bRet = YES;
				break;
			}
			case 0x300B: // 》
			{
				bRet = YES;
				break;
			}
			case 0x3009: // 〉
			{
				bRet = YES;
				break;
			}
			case 0x300D: // 」
			{
				bRet = YES;
				break;
			}
			case 0xFE43: // ﹃
			{
				bRet = YES;
				break;
			}
			case 0x3015: // 〕
			{
				bRet = YES;
				break;
			}
			case 0xFE41: // ﹁
			{
				bRet = YES;
				break;
			}
			case 0x3011: // 】
			{
				bRet = YES;
				break;
			}
			case 0xFE4F: // ﹏
			{
				bRet = YES;
				break;
			}
			case 0xFF5E: // ～
			{
				bRet = YES;
				break;
			}
			case 0x2026: // …
			{
				bRet = YES;
				break;
			}
			case 0x2014: // —
			{
				bRet = YES;
				break;
			}
			case 0x300F: // 』
			{
				bRet = YES;
				break;
			}
			case 0x3017: // 〗
			{
				bRet = YES;
				break;
			}
			default:
			{
				break;
			}
		}
	}
	
	return bRet;
}

+ (BOOL)isPrePartOfPairMarkChar:(unichar)markChar
{
	BOOL bRet = NO;
	
	if (40 <= markChar && markChar < 124)
	{
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
		}
	}
	else if (markChar > 0x2017)
	{
		///                              {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F};
		static char keyIndexTable1[16] = {0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1};
		static char keyIndexTable2[16] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1};
		
		if (keyIndexTable1[(markChar >> 12)& 0x0f] && keyIndexTable2[(markChar >> 8)& 0x0f])
		{
//			NSLog(@"\n====[%X, %d, %@]", markChar, markChar, [NSString stringWithCharacters:&markChar length:1]);
			switch (markChar)
			{
				case 0x2018: // ‘
				{
					bRet = YES;
					break;
				}
				case 0xFF08: // （
				{
					bRet = YES;
					break;
				}
				case 0xFF5B: // ｛
				{
					bRet = YES;
					break;
				}
				case 0x300A: // 《
				{
					bRet = YES;
					break;
				}
				case 0x3008: // 〈
				{
					bRet = YES;
					break;
				}
				case 0xFE44: // ﹄
				{
					bRet = YES;
					break;
				}
				case 0xFE42: // ﹂
				{
					bRet = YES;
					break;
				}
				case 0x3014: // 〔
				{
					bRet = YES;
					break;
				}
				case 0x3010: // 【
				{
					bRet = YES;
					break;
				}
				case 0x300C: // 「
				{
					bRet = YES;
					break;
				}
				case 0x300E: // 『
				{
					bRet = YES;
					break;
				}
				case 0x3016: // 〖
				{
					bRet = YES;
					break;
				}
				default:
				{
					break;
				}
			}
		}
	}
	
	return bRet;
}

@end

