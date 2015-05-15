
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



#import <Foundation/Foundation.h>


@interface NBLayouterHelper : NSObject


+ (BOOL)isDashOrEllipsis:(NSString*)lastAndNextChar;

+ (BOOL)isPrePartOfPairMarkChar2:(unichar)markChar;
+ (BOOL)isPrePartOfPairMarkChar:(NSString*)oneChar;

+ (BOOL)isSpecialMarkChar:(NSString*)oneChar;

+ (NSInteger)getSpecialMarkCharCount:(NSString*)checkStr;


@end

