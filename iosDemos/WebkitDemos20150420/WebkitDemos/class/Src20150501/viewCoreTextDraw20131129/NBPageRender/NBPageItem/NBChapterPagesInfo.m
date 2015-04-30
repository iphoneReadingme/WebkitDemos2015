/*
 *****************************************************************************
 * Copyright (C) 2005-2013 UC Mobile Limited. All Rights Reserved
 * File			: NBChapterPagesInfo.m
 *
 * Description	: NBChapterPagesInfo
 *
 * Author		: daijb@ucweb.com
 * History		:
 *			   Creation, 14-6-17, daijb@ucweb.com, Create the file
 ******************************************************************************
 **/

#import "NBChapterPagesInfo.h"

#pragma mark - NBChapterPagesInfo

@implementation NBChapterPagesInfo

- (void)dealloc
{
	self.pageItems = nil;
	self.errorSubstitute = nil;
	
	[super dealloc];
}

#pragma mark - Serialize of NBPageItem
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.pageItems forKey:@"pageItems"];
    [encoder encodeBool:self.isSplitError forKey:@"isSplitError"];
    [encoder encodeObject:self.errorSubstitute forKey:@"errorSubstitute"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
		self.pageItems = [decoder decodeObjectForKey:@"pageItems"];
		self.isSplitError = [decoder decodeBoolForKey:@"isSplitError"];
		self.errorSubstitute = [decoder decodeObjectForKey:@"errorSubstitute"];
    }
    
    return self;
}

#pragma mark - NSCopying of NBChapterPagesInfo

- (id)copyWithZone:(NSZone *)zone
{
    NBChapterPagesInfo * item = [[[self class] allocWithZone:zone] init];
	item.pageItems = [[self.pageItems mutableCopy] autorelease];
    item.isSplitError = self.isSplitError;
    item.errorSubstitute = self.errorSubstitute;
    
    return item;
}

- (NSUInteger)getPagesCount
{
    return [self.pageItems count];
}

- (NBPageItem*)getPageItem:(NSInteger)pageIndex
{
    NBPageItem * item = nil;
    if ((pageIndex >= 0) & (pageIndex < [self getPagesCount]))
    {
        item = [self.pageItems objectAtIndex:pageIndex];
    }
    
    return item;
}

@end
