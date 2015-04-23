//
//  DetailViewController.h
//  WebkitDemos
//
//  Created by yangfs on 15/4/20.
//  Copyright (c) 2015年 yangfs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

