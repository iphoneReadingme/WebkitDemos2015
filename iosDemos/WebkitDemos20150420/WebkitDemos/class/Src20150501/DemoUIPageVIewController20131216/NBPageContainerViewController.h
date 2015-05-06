
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: NBPageContainerViewController.h
 *
 * Description	: NBPageContainerViewController书页内容控制器,用于显示页面内容
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-05.
 * History		: modify: 2015-05-05.
 *
 ******************************************************************************
 **/


#import <UIKit/UIKit.h>



@protocol NBPageContainerViewControllerDelegate <NSObject>

@optional
- (void)setCurChapterName:(NSString*)chapterName;

@end



@interface NBPageContainerViewController : UIViewController
{
}

@property (nonatomic, assign) id<NBPageContainerViewControllerDelegate> delegate;


+ (NBPageContainerViewController*)getPageViewControllerForPageIndex:(NSInteger)pageIndex withDelegate:(id<NBPageContainerViewControllerDelegate>)delegate;

- (NSInteger)pageIndex;

@end

