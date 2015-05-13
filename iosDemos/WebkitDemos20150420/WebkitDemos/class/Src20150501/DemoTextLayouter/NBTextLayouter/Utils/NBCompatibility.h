
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBCompatibility.h
 *
 * Description	: NBCompatibility
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-07.
 * History		: modify: 2015-05-07.
 *
 ******************************************************************************
 **/


#import <Foundation/Foundation.h>

#pragma mark - iOS

// NS-style text attributes are possible with iOS SDK 6.0 or higher
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
#define DTCORETEXT_SUPPORT_NS_ATTRIBUTES 1
#endif


// runtime-check if NS-style attributes are allowed
static inline BOOL NBModernAttributesPossible()
{
	if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_6_0)
	{
		return YES;
	}
	return NO;
}

