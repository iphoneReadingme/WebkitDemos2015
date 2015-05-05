
/*
 *****************************************************************************
 * Copyright (C) 2005-2013 readbookamazon@126.com. All Rights Reserved
 * File			: TextPageViewController.h
 *
 * Description	: TextPageViewController书页内容控制器,用于显示页面内容
 *
 * Author		: yangfs@ucweb.com
 *
 * Created by yangfs on   2015-05-05.
 * History		: modify: 2015-05-05.
 *
 ******************************************************************************
 **/


#import <UIKit/UIKit.h>



@protocol TextPageViewControllerDelegate <NSObject>

@optional
- (void)setCurChapterName:(NSString*)chapterName;

@end



@interface TextPageViewController : UIViewController
{
}

@property (nonatomic, assign) id<TextPageViewControllerDelegate> delegate;


+ (TextPageViewController*)getPageViewControllerForPageIndex:(NSUInteger)pageIndex withDelegate:(id<TextPageViewControllerDelegate>)delegate;

- (NSInteger)pageIndex;

@end

